import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_store.dart';
import '../../models/coffee_lot.dart';
import '../../services/home_tab_notifier.dart';
import '../../services/session_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/focus_utils.dart';
import 'filters_sheet.dart';
import 'list_mode_view.dart';
import 'search_screen.dart';
import 'swipe_mode_view.dart';

enum ModoDescubrimiento { tarjetas, lista }

/// Pantalla principal del comprador.
///
/// Causa raíz del teclado "fantasma" (corregida): antes esta pantalla tenía un
/// TextField permanente. Cuando ese campo había tenido foco alguna vez,
/// Flutter lo restauraba al volver de modales (filtros, orden) o de otras
/// rutas (perfil), abriendo el teclado y reacomodando todo. Ahora Descubrir NO
/// contiene ningún campo de texto: la búsqueda vive en [SearchScreen], una
/// ruta aparte. Sin campo enfocable no hay foco que restaurar.
///
/// Rendimiento: no observa el MockStore. Recarga la lista solo en momentos
/// seguros (aplicar búsqueda/filtros/orden, volver de un detalle o reactivar
/// la pestaña) y únicamente si el catálogo cambió (`catalogRevision`); jamás
/// en mitad de un swipe, para no desordenar el mazo.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  ModoDescubrimiento _modo = ModoDescubrimiento.tarjetas;
  DiscoverFilters _filtros = const DiscoverFilters();
  List<CoffeeLot> _lotes = [];
  int _versionMazo = 0; // cambia en cada recarga para reiniciar el CardSwiper limpio
  int _revisionCargada = -1;
  bool _inicializado = false;
  bool _pestanaActivaAnterior = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      _lotes = _consultar(); // síncrono: el primer frame ya tiene datos (sin parpadeo de "vacío")
    }
  }

  List<CoffeeLot> _consultar() {
    final store = context.read<MockStore>();
    final uid = context.read<SessionProvider>().usuario!.uid;
    _revisionCargada = store.catalogRevision;
    return store.descubrirLotes(compradorId: uid, filtros: _filtros);
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _lotes = _consultar();
      _versionMazo++;
    });
  }

  /// Recarga solo si algo del catálogo cambió desde la última carga.
  void _recargarSiCambio() {
    if (!mounted) return;
    if (context.read<MockStore>().catalogRevision != _revisionCargada) _recargar();
  }

  Future<void> _abrirBusqueda() async {
    liberarFoco();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          filtrosBase: _filtros,
          onQueryChanged: (q) => _filtros = _filtros.copyWith(busqueda: q),
        ),
      ),
    );
    if (!mounted) return;
    liberarFoco();
    _recargar();
  }

  Future<void> _abrirFiltros() async {
    liberarFoco();
    final resultado = await mostrarFiltros(context, _filtros);
    if (!mounted) return;
    liberarFoco();
    if (resultado != null) {
      _filtros = resultado;
      _recargar();
    }
  }

  Future<void> _elegirOrden() async {
    liberarFoco();
    final elegido = await showModalBottomSheet<DiscoverSort>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(alignment: Alignment.centerLeft, child: Text('Ordenar por', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ),
            ...DiscoverSort.values.map((s) => RadioListTile<DiscoverSort>(
                  title: Text(s.label),
                  value: s,
                  groupValue: _filtros.orden,
                  activeColor: AppColors.coffeeMedium,
                  onChanged: (v) => Navigator.pop(context, v),
                )),
          ],
        ),
      ),
    );
    if (!mounted) return;
    liberarFoco();
    if (elegido != null && elegido != _filtros.orden) {
      _filtros = _filtros.copyWith(orden: elegido);
      _recargar();
    }
  }

  void _limpiarFiltros() {
    _filtros = DiscoverFilters(busqueda: _filtros.busqueda, orden: _filtros.orden);
    _recargar();
  }

  void _limpiarBusqueda() {
    _filtros = _filtros.copyWith(busqueda: '');
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    // Al volver a la pestaña Descubrir se revisa (una vez) si el catálogo cambió.
    final activa = context.select<HomeTabNotifier, bool>((t) => t.indice == 0);
    if (activa && !_pestanaActivaAnterior) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recargarSiCambio());
    }
    _pestanaActivaAnterior = activa;

    final nFiltros = _filtros.numFiltrosActivos;
    final hayBusqueda = _filtros.hayBusqueda;

    return Scaffold(
      // Descubrir no contiene campos de texto: el teclado nunca debe
      // reacomodar su layout, y la tarjeta conserva posición y escala.
      // (La búsqueda, que sí usa teclado, es otra ruta con su propio Scaffold.)
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Descubrir café'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar café',
            iconSize: 26,
            onPressed: _abrirBusqueda,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Encuentra tu próximo café', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 1),
                Text('Explora productores, origen y variedades.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _BotonControl(
                        icono: Icons.tune,
                        etiqueta: nFiltros > 0 ? 'Filtrar · $nFiltros' : 'Filtrar',
                        destacado: nFiltros > 0,
                        onTap: _abrirFiltros,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BotonControl(
                        icono: Icons.sort,
                        etiqueta: 'Ordenar',
                        destacado: _filtros.orden != DiscoverSort.relevancia,
                        onTap: _elegirOrden,
                      ),
                    ),
                  ],
                ),
                if (hayBusqueda || nFiltros > 0) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (hayBusqueda)
                        InputChip(
                          label: Text('Búsqueda: ${_filtros.busqueda.trim()}', style: const TextStyle(fontSize: 12)),
                          onDeleted: _limpiarBusqueda,
                          deleteButtonTooltipMessage: 'Quitar búsqueda',
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          backgroundColor: AppColors.coffeeLight.withOpacity(0.3),
                          side: BorderSide.none,
                        ),
                      if (nFiltros > 0)
                        TextButton(
                          onPressed: _limpiarFiltros,
                          style: TextButton.styleFrom(minimumSize: const Size(48, 40), padding: const EdgeInsets.symmetric(horizontal: 6)),
                          child: Text('$nFiltros ${nFiltros == 1 ? 'filtro activo' : 'filtros activos'} · Limpiar', style: const TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_lotes.length} ${_lotes.length == 1 ? 'café encontrado' : 'cafés encontrados'}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5),
                      ),
                    ),
                    _SelectorModo(modo: _modo, onChanged: (m) => setState(() => _modo = m)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _lotes.isEmpty
                ? _EstadoVacio(
                    hayBusqueda: hayBusqueda,
                    hayFiltros: nFiltros > 0,
                    consulta: _filtros.busqueda.trim(),
                    onLimpiarFiltros: _limpiarFiltros,
                    onLimpiarBusqueda: _limpiarBusqueda,
                    onVerGuardados: () => context.read<HomeTabNotifier>().ir(2),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _modo == ModoDescubrimiento.tarjetas
                        ? SwipeModeView(
                            key: ValueKey('mazo_$_versionMazo'),
                            lotes: _lotes,
                            onCambioLista: () => setState(() => _modo = ModoDescubrimiento.lista),
                            onRegresoDeDetalle: _recargarSiCambio,
                          )
                        : ListModeView(
                            key: ValueKey('lista_$_versionMazo'),
                            lotes: _lotes,
                            onRegresoDeDetalle: _recargarSiCambio,
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Botón secundario compacto (Filtrar / Ordenar): 40 px de alto, no compite
/// con la fotografía. Área táctil suficiente y estado "activo" visible.
class _BotonControl extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final bool destacado;
  final VoidCallback onTap;

  const _BotonControl({required this.icono, required this.etiqueta, required this.destacado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = destacado ? AppColors.coffeeMedium : AppColors.coffeeDark;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icono, size: 17, color: color),
      label: Text(etiqueta, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: destacado ? AppColors.coffeeLight.withOpacity(0.25) : Colors.white,
        side: BorderSide(color: destacado ? AppColors.coffeeMedium : AppColors.coffeeLight),
      ),
    );
  }
}

/// Estados vacíos diferenciados: (1) sin resultados por filtros,
/// (2) sin resultados solo por búsqueda, (3) sin más cafés por descubrir.
class _EstadoVacio extends StatelessWidget {
  final bool hayBusqueda;
  final bool hayFiltros;
  final String consulta;
  final VoidCallback onLimpiarFiltros;
  final VoidCallback onLimpiarBusqueda;
  final VoidCallback onVerGuardados;

  const _EstadoVacio({
    required this.hayBusqueda,
    required this.hayFiltros,
    required this.consulta,
    required this.onLimpiarFiltros,
    required this.onLimpiarBusqueda,
    required this.onVerGuardados,
  });

  @override
  Widget build(BuildContext context) {
    late final String titulo;
    late final String detalle;
    final acciones = <Widget>[];

    if (hayFiltros) {
      titulo = 'No encontramos cafés con esos criterios';
      detalle = 'Prueba eliminando un filtro o cambia la búsqueda.';
      acciones.add(_accion('Limpiar filtros', onLimpiarFiltros, principal: true));
      if (hayBusqueda) acciones.add(_accion('Limpiar búsqueda', onLimpiarBusqueda));
    } else if (hayBusqueda) {
      titulo = 'Sin resultados para “$consulta”';
      detalle = 'Revisa la ortografía o prueba con otra variedad, finca o región.';
      acciones.add(_accion('Limpiar búsqueda', onLimpiarBusqueda, principal: true));
    } else {
      titulo = 'Ya viste todos los cafés disponibles';
      detalle = 'Los vendedores publican lotes nuevos con frecuencia. Mientras tanto, revisa los que guardaste.';
      acciones.add(_accion('Ver guardados', onVerGuardados, principal: true));
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.coffee_outlined, size: 52, color: AppColors.coffeeLight),
            const SizedBox(height: 14),
            Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
            const SizedBox(height: 6),
            Text(detalle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 16),
            ...acciones,
          ],
        ),
      ),
    );
  }

  Widget _accion(String texto, VoidCallback onTap, {bool principal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: principal
          ? ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(200, 44)), onPressed: onTap, child: Text(texto))
          : OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size(200, 44)), onPressed: onTap, child: Text(texto)),
    );
  }
}

/// Selector Tarjetas | Lista compacto (34 px de alto).
class _SelectorModo extends StatelessWidget {
  final ModoDescubrimiento modo;
  final ValueChanged<ModoDescubrimiento> onChanged;

  const _SelectorModo({required this.modo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.coffeeLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _opcion(ModoDescubrimiento.tarjetas, Icons.style_outlined, 'Tarjetas'),
          _opcion(ModoDescubrimiento.lista, Icons.view_list_outlined, 'Lista'),
        ],
      ),
    );
  }

  Widget _opcion(ModoDescubrimiento valor, IconData icono, String texto) {
    final activo = modo == valor;
    return Semantics(
      button: true,
      selected: activo,
      label: 'Modo $texto',
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => onChanged(valor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: activo ? AppColors.coffeeMedium : Colors.transparent, borderRadius: BorderRadius.circular(9)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 15, color: activo ? Colors.white : AppColors.coffeeDark),
              const SizedBox(width: 4),
              Text(texto, style: TextStyle(color: activo ? Colors.white : AppColors.coffeeDark, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
