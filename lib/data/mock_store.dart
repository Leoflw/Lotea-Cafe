import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/seller_profile.dart';
import '../models/coffee_lot.dart';
import '../models/interest_request.dart';
import '../models/favorite.dart';
import '../models/quote_request.dart';
import '../models/chat_message.dart';

class AuthException implements Exception {
  final String mensaje;
  AuthException(this.mensaje);
}

class DuplicateRequestException implements Exception {
  final String mensaje;
  DuplicateRequestException(this.mensaje);
}

enum DiscoverSort { relevancia, precioAsc, precioDesc, puntajeDesc, recientes, disponibilidad }

extension DiscoverSortX on DiscoverSort {
  String get label {
    switch (this) {
      case DiscoverSort.relevancia:
        return 'Más relevantes';
      case DiscoverSort.precioAsc:
        return 'Precio: menor a mayor';
      case DiscoverSort.precioDesc:
        return 'Precio: mayor a menor';
      case DiscoverSort.puntajeDesc:
        return 'Mayor puntaje';
      case DiscoverSort.recientes:
        return 'Más recientes';
      case DiscoverSort.disponibilidad:
        return 'Mayor disponibilidad';
    }
  }
}

/// Filtros de descubrimiento (sección 14 del plan de evolución). Vive aquí
/// (y no en la capa de UI) porque también lo usará la búsqueda en modo lista.
class DiscoverFilters {
  final List<String> departamentos;
  final List<String> variedades;
  final List<String> procesos;
  final double? precioMinCOP;
  final double? precioMaxCOP;
  final double? altitudMin;
  final double? altitudMax;
  final double? puntajeMin;
  final List<String> certificaciones;
  final bool soloDisponibles;
  final String? tipoCafe;
  final bool soloVerificados;
  final String busqueda;
  final DiscoverSort orden;

  const DiscoverFilters({
    this.departamentos = const [],
    this.variedades = const [],
    this.procesos = const [],
    this.precioMinCOP,
    this.precioMaxCOP,
    this.altitudMin,
    this.altitudMax,
    this.puntajeMin,
    this.certificaciones = const [],
    this.soloDisponibles = false,
    this.tipoCafe,
    this.soloVerificados = false,
    this.busqueda = '',
    this.orden = DiscoverSort.relevancia,
  });

  DiscoverFilters copyWith({
    List<String>? departamentos,
    List<String>? variedades,
    List<String>? procesos,
    double? precioMinCOP,
    double? precioMaxCOP,
    double? altitudMin,
    double? altitudMax,
    double? puntajeMin,
    List<String>? certificaciones,
    bool? soloDisponibles,
    String? tipoCafe,
    bool? soloVerificados,
    String? busqueda,
    DiscoverSort? orden,
  }) {
    return DiscoverFilters(
      departamentos: departamentos ?? this.departamentos,
      variedades: variedades ?? this.variedades,
      procesos: procesos ?? this.procesos,
      precioMinCOP: precioMinCOP ?? this.precioMinCOP,
      precioMaxCOP: precioMaxCOP ?? this.precioMaxCOP,
      altitudMin: altitudMin ?? this.altitudMin,
      altitudMax: altitudMax ?? this.altitudMax,
      puntajeMin: puntajeMin ?? this.puntajeMin,
      certificaciones: certificaciones ?? this.certificaciones,
      soloDisponibles: soloDisponibles ?? this.soloDisponibles,
      tipoCafe: tipoCafe ?? this.tipoCafe,
      soloVerificados: soloVerificados ?? this.soloVerificados,
      busqueda: busqueda ?? this.busqueda,
      orden: orden ?? this.orden,
    );
  }

  /// Cantidad de GRUPOS de filtro activos (no de opciones individuales):
  /// departamento, variedad, proceso, precio, altitud, puntaje,
  /// certificaciones, disponibilidad, tipo de café y verificación. La búsqueda
  /// y el orden NO cuentan como filtros.
  int get numFiltrosActivos =>
      (departamentos.isNotEmpty ? 1 : 0) +
      (variedades.isNotEmpty ? 1 : 0) +
      (procesos.isNotEmpty ? 1 : 0) +
      ((precioMinCOP != null || precioMaxCOP != null) ? 1 : 0) +
      ((altitudMin != null || altitudMax != null) ? 1 : 0) +
      (puntajeMin != null ? 1 : 0) +
      (certificaciones.isNotEmpty ? 1 : 0) +
      (soloDisponibles ? 1 : 0) +
      (tipoCafe != null ? 1 : 0) +
      (soloVerificados ? 1 : 0);

  bool get tieneFiltrosActivos => numFiltrosActivos > 0;
  bool get hayBusqueda => busqueda.trim().isNotEmpty;
}

/// "Backend" en memoria para esta build de pruebas. Organizado en
/// colecciones equivalentes a las que tendría Firestore, para que migrar a
/// Firestore más adelante sea un cambio de capa de datos, no de arquitectura:
/// usuarios · vendedores · lotes · solicitudes · favoritos · cotizaciones · mensajes
class MockStore extends ChangeNotifier {
  final List<AppUser> _usuarios = [];
  final Map<String, String> _passwords = {};
  final List<SellerProfile> _vendedores = [];
  final List<CoffeeLot> _lotes = [];
  final List<InterestRequest> _solicitudes = [];
  final List<Favorite> _favoritos = [];
  final List<QuoteRequest> _cotizaciones = [];
  final Map<String, List<ChatMessage>> _mensajes = {};

  int _contador = 0;
  String _nuevoId(String prefijo) => '$prefijo${_contador++}';

  /// Se incrementa SOLO cuando cambia algo que afecta qué cafés puede ver un
  /// comprador (lotes, perfiles, solicitudes, descartes). Permite a
  /// Descubrir recargar únicamente cuando hace falta, sin reconstruirse por
  /// cada mensaje de chat o favorito.
  int _catalogRevision = 0;
  int get catalogRevision => _catalogRevision;
  void _bumpCatalogo() => _catalogRevision++;

  MockStore() {
    _sembrarDatosDemo();
  }

  // ---------------------------------------------------------------------
  // AUTENTICACIÓN
  // ---------------------------------------------------------------------

  AppUser registrar({
    required String email,
    required String password,
    required String nombre,
    required UserRole rol,
  }) {
    final emailNormalizado = email.trim().toLowerCase();
    if (_passwords.containsKey(emailNormalizado)) {
      throw AuthException('Ese correo ya está registrado en esta sesión de prueba.');
    }
    final usuario = AppUser(
      uid: _nuevoId('user_'),
      email: emailNormalizado,
      nombre: nombre.trim(),
      rol: rol,
    );
    _usuarios.add(usuario);
    _passwords[emailNormalizado] = password;
    notifyListeners();
    return usuario;
  }

  AppUser iniciarSesion({required String email, required String password}) {
    final emailNormalizado = email.trim().toLowerCase();
    final claveGuardada = _passwords[emailNormalizado];
    if (claveGuardada == null || claveGuardada != password) {
      throw AuthException('Correo o contraseña incorrectos.');
    }
    return _usuarios.firstWhere((u) => u.email == emailNormalizado);
  }

  void actualizarUsuario(AppUser usuario) {
    final i = _usuarios.indexWhere((u) => u.uid == usuario.uid);
    if (i != -1) _usuarios[i] = usuario;
    notifyListeners();
  }

  AppUser? usuarioPorId(String uid) {
    for (final u in _usuarios) {
      if (u.uid == uid) return u;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // PERFIL DE VENDEDOR
  // ---------------------------------------------------------------------

  void guardarPerfilVendedor(SellerProfile perfil) {
    _vendedores.removeWhere((v) => v.id == perfil.id);
    _vendedores.add(perfil);
    _bumpCatalogo();
    notifyListeners();
  }

  SellerProfile? obtenerPerfilVendedor(String usuarioId) {
    for (final v in _vendedores) {
      if (v.usuarioId == usuarioId) return v;
    }
    return null;
  }

  SellerProfile? perfilVendedorPorId(String sellerId) {
    for (final v in _vendedores) {
      if (v.id == sellerId) return v;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // LOTES DE CAFÉ
  // ---------------------------------------------------------------------

  void guardarLote(CoffeeLot lote) {
    _lotes.removeWhere((l) => l.id == lote.id);
    _lotes.add(lote);
    _bumpCatalogo();
    notifyListeners();
  }

  void eliminarLote(String loteId) {
    _lotes.removeWhere((l) => l.id == loteId);
    _bumpCatalogo();
    notifyListeners();
  }

  List<CoffeeLot> lotesDeVendedor(String sellerId) {
    return _lotes.where((l) => l.sellerId == sellerId).toList()
      ..sort((a, b) => (b.fechaPublicacion ?? DateTime(2000))
          .compareTo(a.fechaPublicacion ?? DateTime(2000)));
  }

  CoffeeLot? lotePorId(String id) {
    for (final l in _lotes) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// Lotes visibles para descubrimiento: publicados, de otros vendedores,
  /// que el comprador no haya descartado/solicitado ya, con filtros,
  /// búsqueda de texto y ordenamiento (secciones 9, 10 y 11 de la 2ª ronda).
  List<CoffeeLot> descubrirLotes({
    required String compradorId,
    DiscoverFilters filtros = const DiscoverFilters(),
  }) {
    final yaDecididos = _solicitudes
        .where((s) => s.compradorId == compradorId && s.estado != EstadoSolicitud.rechazada)
        .map((s) => s.coffeeLotId)
        .toSet();
    final descartados = _descartes[compradorId]?.toSet() ?? <String>{};
    final query = _normalizar(filtros.busqueda.trim());

    var resultado = _lotes.where((l) {
      if (!l.publicado) return false;
      if (l.sellerId == compradorId) return false;
      if (yaDecididos.contains(l.id)) return false;
      if (descartados.contains(l.id)) return false;

      final vendedor = perfilVendedorPorId(l.sellerId);

      if (filtros.departamentos.isNotEmpty &&
          (vendedor == null || !filtros.departamentos.contains(vendedor.departamento))) {
        return false;
      }
      if (filtros.variedades.isNotEmpty && !l.variedades.any(filtros.variedades.contains)) {
        return false;
      }
      if (filtros.procesos.isNotEmpty && !filtros.procesos.contains(l.proceso)) {
        return false;
      }
      if (filtros.precioMinCOP != null && l.precioCOP < filtros.precioMinCOP!) return false;
      if (filtros.precioMaxCOP != null && l.precioCOP > filtros.precioMaxCOP!) return false;
      if (filtros.altitudMin != null &&
          (l.altitudMsnm == null || l.altitudMsnm! < filtros.altitudMin!)) {
        return false;
      }
      if (filtros.altitudMax != null &&
          (l.altitudMsnm == null || l.altitudMsnm! > filtros.altitudMax!)) {
        return false;
      }
      if (filtros.puntajeMin != null &&
          (l.puntajeTaza == null || l.puntajeTaza! < filtros.puntajeMin!)) {
        return false;
      }
      if (filtros.certificaciones.isNotEmpty &&
          !l.certificaciones.any(filtros.certificaciones.contains)) {
        return false;
      }
      if (filtros.soloDisponibles && !l.disponible) return false;
      if (filtros.tipoCafe != null && l.tipoCafe != filtros.tipoCafe) return false;
      if (filtros.soloVerificados && (vendedor == null || !vendedor.verificado)) return false;

      if (query.isNotEmpty) {
        final vendedorTexto = vendedor == null
            ? ''
            : '${vendedor.nombreMarca} ${vendedor.fincaPrincipal} ${vendedor.region} '
                '${vendedor.departamento} ${vendedor.municipio}';
        final textoBusqueda = _normalizar(
            '${l.nombre} ${l.variedades.join(' ')} ${l.proceso} ${l.tipoCafe ?? ''} $vendedorTexto');
        if (!textoBusqueda.contains(query)) return false;
      }

      return true;
    }).toList();

    final comprador = usuarioPorId(compradorId);
    resultado.sort((a, b) => _compararSegunOrden(a, b, filtros.orden, comprador));
    return resultado;
  }

  /// Minúsculas y sin tildes, para que "narino" encuentre "Nariño".
  static String _normalizar(String texto) {
    const conTilde = 'áàäâéèëêíìïîóòöôúùüûñ';
    const sinTilde = 'aaaaeeeeiiiioooouuuun';
    final buffer = StringBuffer();
    for (final ch in texto.toLowerCase().split('')) {
      final i = conTilde.indexOf(ch);
      buffer.write(i == -1 ? ch : sinTilde[i]);
    }
    return buffer.toString();
  }

  int _compararSegunOrden(CoffeeLot a, CoffeeLot b, DiscoverSort orden, AppUser? comprador) {
    switch (orden) {
      case DiscoverSort.precioAsc:
        return a.precioCOP.compareTo(b.precioCOP);
      case DiscoverSort.precioDesc:
        return b.precioCOP.compareTo(a.precioCOP);
      case DiscoverSort.puntajeDesc:
        return (b.puntajeTaza ?? 0).compareTo(a.puntajeTaza ?? 0);
      case DiscoverSort.recientes:
        return (b.fechaPublicacion ?? DateTime(2000)).compareTo(a.fechaPublicacion ?? DateTime(2000));
      case DiscoverSort.disponibilidad:
        return (b.cantidadDisponibleKg ?? 0).compareTo(a.cantidadDisponibleKg ?? 0);
      case DiscoverSort.relevancia:
        if (comprador == null) return 0;
        final porPuntaje = puntuarLote(b, comprador).compareTo(puntuarLote(a, comprador));
        if (porPuntaje != 0) return porPuntaje;
        // Desempate simple y explicable: más reciente primero.
        return (b.fechaPublicacion ?? DateTime(2000)).compareTo(a.fechaPublicacion ?? DateTime(2000));
    }
  }

  /// Cuántas de las preferencias DIRECTAS del comprador (variedad, proceso,
  /// región) configuró, y cuántas de ellas coinciden con el lote. Una
  /// categoría sin configurar no cuenta ni a favor ni en contra.
  ({int configuradas, int coincidencias}) _coincidenciasDirectas(CoffeeLot lote, AppUser comprador) {
    final prefs = comprador.preferencias;
    final vendedor = perfilVendedorPorId(lote.sellerId);
    int configuradas = 0;
    int coincidencias = 0;
    if (prefs.variedades.isNotEmpty) {
      configuradas++;
      if (lote.variedades.any(prefs.variedades.contains)) coincidencias++;
    }
    if (prefs.procesos.isNotEmpty) {
      configuradas++;
      if (prefs.procesos.contains(lote.proceso)) coincidencias++;
    }
    if (prefs.regiones.isNotEmpty) {
      configuradas++;
      if (vendedor != null && prefs.regiones.contains(vendedor.departamento)) coincidencias++;
    }
    return (configuradas: configuradas, coincidencias: coincidencias);
  }

  /// Puntuación de relevancia de 0 a 100, simple y explicable:
  ///   55  preferencias directas (variedad/proceso/región): proporción de las
  ///       configuradas que coinciden
  ///   15  precio: dentro del máximo del comprador (7.5 si no definió máximo)
  ///   15  disponibilidad: el lote está disponible
  ///   15  calidad: puntaje de taza de 75 a 95, escalado (complemento)
  /// Sin IA: solo reglas sobre datos que ya existen en el modelo.
  double puntuarLote(CoffeeLot lote, AppUser comprador) {
    final d = _coincidenciasDirectas(lote, comprador);
    final directo = d.configuradas == 0 ? 0.0 : 55.0 * d.coincidencias / d.configuradas;
    final maxPrecio = comprador.preferencias.precioMaxCOP;
    final precio = maxPrecio == null ? 7.5 : (lote.precioCOP <= maxPrecio ? 15.0 : 0.0);
    final disponibilidad = lote.disponible ? 15.0 : 0.0;
    final calidad = lote.puntajeTaza == null
        ? 0.0
        : 15.0 * ((lote.puntajeTaza! - 75) / 20).clamp(0.0, 1.0).toDouble();
    return directo + precio + disponibilidad + calidad;
  }

  /// true SOLO si el café coincide de forma sustancial con lo que el
  /// comprador pidió: está disponible, respeta su precio máximo (si lo definió)
  /// y coincide con TODAS sus preferencias directas si configuró una o con al
  /// menos dos si configuró varias. Un solo dato suelto no basta.
  bool coincideConPreferencias(CoffeeLot lote, AppUser comprador) {
    final d = _coincidenciasDirectas(lote, comprador);
    if (d.configuradas == 0 || d.coincidencias == 0) return false;
    if (!lote.disponible) return false;
    final maxPrecio = comprador.preferencias.precioMaxCOP;
    if (maxPrecio != null && lote.precioCOP > maxPrecio) return false;
    return d.configuradas == 1 || d.coincidencias >= 2;
  }

  // Descartes ("no me interesa") por comprador — no generan registro
  // comercial, solo evitan que el lote se repita en el feed durante la
  // sesión. Se guardan en orden de inserción para poder deshacer el último.
  final Map<String, List<String>> _descartes = {};

  void descartarLote({required String compradorId, required String coffeeLotId}) {
    final lista = _descartes.putIfAbsent(compradorId, () => []);
    if (!lista.contains(coffeeLotId)) lista.add(coffeeLotId);
    _bumpCatalogo();
    notifyListeners();
  }

  /// Deshace únicamente el último descarte del comprador (sección 15).
  String? deshacerUltimoDescarte(String compradorId) {
    final lista = _descartes[compradorId];
    if (lista == null || lista.isEmpty) return null;
    final id = lista.removeLast();
    _bumpCatalogo();
    notifyListeners();
    return id;
  }

  // ---------------------------------------------------------------------
  // SOLICITUDES COMERCIALES ("Me interesa")
  // ---------------------------------------------------------------------

  InterestRequest crearSolicitud({
    required String compradorId,
    required CoffeeLot lote,
    String? mensaje,
  }) {
    final existente = _solicitudes.where(
      (s) => s.compradorId == compradorId && s.coffeeLotId == lote.id && s.estado != EstadoSolicitud.rechazada,
    );
    if (existente.isNotEmpty) {
      final estado = existente.first.estado;
      throw DuplicateRequestException(
        estado == EstadoSolicitud.aceptada
            ? 'Ya tienes una conexión comercial con este vendedor para este café.'
            : 'Ya has enviado una solicitud para este café. Espera la respuesta del vendedor.',
      );
    }
    final solicitud = InterestRequest(
      id: _nuevoId('solicitud_'),
      compradorId: compradorId,
      sellerId: lote.sellerId,
      coffeeLotId: lote.id,
      mensaje: mensaje,
    );
    _solicitudes.add(solicitud);
    _bumpCatalogo();
    notifyListeners();
    return solicitud;
  }

  void aceptarSolicitud(String solicitudId) {
    _actualizarEstadoSolicitud(solicitudId, EstadoSolicitud.aceptada);
  }

  void rechazarSolicitud(String solicitudId) {
    _actualizarEstadoSolicitud(solicitudId, EstadoSolicitud.rechazada);
  }

  void _actualizarEstadoSolicitud(String id, EstadoSolicitud nuevoEstado) {
    final i = _solicitudes.indexWhere((s) => s.id == id);
    if (i != -1) {
      _solicitudes[i] = _solicitudes[i].copyWith(estado: nuevoEstado);
      _bumpCatalogo();
      notifyListeners();
    }
  }

  List<InterestRequest> solicitudesEnviadas(String compradorId) {
    return _solicitudes.where((s) => s.compradorId == compradorId).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  List<InterestRequest> solicitudesRecibidas(String sellerId) {
    return _solicitudes.where((s) => s.sellerId == sellerId).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  List<InterestRequest> conexionesComprador(String compradorId) {
    return solicitudesEnviadas(compradorId).where((s) => s.esConexion).toList();
  }

  List<InterestRequest> conexionesVendedor(String sellerId) {
    return solicitudesRecibidas(sellerId).where((s) => s.esConexion).toList();
  }

  InterestRequest? solicitudPorId(String id) {
    for (final s in _solicitudes) {
      if (s.id == id) return s;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // FAVORITOS / GUARDADOS
  // ---------------------------------------------------------------------

  bool esFavorito({required String compradorId, required TipoFavorito tipo, required String refId}) {
    return _favoritos.any((f) => f.compradorId == compradorId && f.tipo == tipo && f.refId == refId);
  }

  void alternarFavorito({
    required String compradorId,
    required TipoFavorito tipo,
    required String refId,
  }) {
    final existente = _favoritos.where(
      (f) => f.compradorId == compradorId && f.tipo == tipo && f.refId == refId,
    );
    if (existente.isNotEmpty) {
      _favoritos.remove(existente.first);
    } else {
      _favoritos.add(Favorite(
        id: _nuevoId('fav_'),
        compradorId: compradorId,
        tipo: tipo,
        refId: refId,
      ));
    }
    notifyListeners();
  }

  List<CoffeeLot> cafesGuardados(String compradorId) {
    final ids = _favoritos
        .where((f) => f.compradorId == compradorId && f.tipo == TipoFavorito.cafe)
        .map((f) => f.refId)
        .toSet();
    return _lotes.where((l) => ids.contains(l.id)).toList();
  }

  List<SellerProfile> vendedoresGuardados(String compradorId) {
    final ids = _favoritos
        .where((f) => f.compradorId == compradorId && f.tipo == TipoFavorito.vendedor)
        .map((f) => f.refId)
        .toSet();
    return _vendedores.where((v) => ids.contains(v.id)).toList();
  }

  // ---------------------------------------------------------------------
  // COTIZACIONES (arquitectura preparada, sección 13)
  // ---------------------------------------------------------------------

  QuoteRequest crearCotizacion({
    required InterestRequest conexion,
    required double cantidad,
    required String unidad,
    String? comentario,
    String? lugarEntrega,
  }) {
    final cotizacion = QuoteRequest(
      id: _nuevoId('cotizacion_'),
      interestRequestId: conexion.id,
      compradorId: conexion.compradorId,
      sellerId: conexion.sellerId,
      coffeeLotId: conexion.coffeeLotId,
      cantidad: cantidad,
      unidad: unidad,
      comentario: comentario,
      lugarEntrega: lugarEntrega,
    );
    _cotizaciones.add(cotizacion);
    notifyListeners();
    return cotizacion;
  }

  List<QuoteRequest> cotizacionesDeConexion(String interestRequestId) {
    return _cotizaciones.where((c) => c.interestRequestId == interestRequestId).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  // ---------------------------------------------------------------------
  // CHAT (solo dentro de una conexión comercial aceptada)
  // ---------------------------------------------------------------------

  List<ChatMessage> mensajesDeChat(String chatId) => _mensajes[chatId] ?? [];

  void enviarMensaje(ChatMessage mensaje) {
    _mensajes.putIfAbsent(mensaje.chatId, () => []).add(mensaje);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // DATOS DE DEMOSTRACIÓN — vendedores y lotes reales de zonas cafeteras
  // colombianas, con precios en COP.
  // ---------------------------------------------------------------------

  void _sembrarDatosDemo() {
    final demo = <Map<String, dynamic>>[
      {
        'marca': 'Finca La Esperanza',
        'vendedor': 'Carlos Ramírez',
        'depto': 'Huila',
        'municipio': 'Pitalito',
        'anios': 18,
        'tipoProd': 'Familiar',
        'verificado': true,
        'historia':
            'Tres generaciones cultivando café de altura en las laderas del Macizo Colombiano, '
                'enfocados en procesos especiales desde 2015.',
        'desc': 'Finca especializada en cafés de alta calidad para tueste de especialidad.',
        'lotes': [
          {'nombre': 'Caturra Lavado', 'var': ['Caturra'], 'proc': 'Lavado', 'alt': 1750.0, 'punt': 86.5, 'precio': 32000.0, 'cert': ['Orgánico']},
          {'nombre': 'Geisha Natural', 'var': ['Geisha'], 'proc': 'Natural', 'alt': 1850.0, 'punt': 89.0, 'precio': 68000.0, 'cert': ['Denominación de origen']},
        ],
      },
      {
        'marca': 'Finca El Mirador',
        'vendedor': 'Ana Gómez',
        'depto': 'Antioquia',
        'municipio': 'Jardín',
        'anios': 9,
        'tipoProd': 'Cooperativa',
        'verificado': true,
        'historia':
            'Cooperativa de 12 familias productoras del suroeste antioqueño, con enfoque en '
                'procesos honey y comercio directo con tostadores.',
        'desc': 'Café dulce y de cuerpo cremoso, ideal para espresso.',
        'lotes': [
          {'nombre': 'Castillo Honey', 'var': ['Castillo'], 'proc': 'Honey', 'alt': 1600.0, 'punt': 84.0, 'precio': 26000.0, 'cert': ['Fair Trade']},
        ],
      },
      {
        'marca': 'Finca Santa Rosa',
        'vendedor': 'Jorge Duarte',
        'depto': 'Nariño',
        'municipio': 'Consacá',
        'anios': 5,
        'tipoProd': 'Familiar',
        'verificado': false,
        'historia': 'Productor de segunda generación explorando fermentaciones controladas.',
        'desc': 'Notas afrutadas gracias al clima frío del altiplano nariñense.',
        'lotes': [
          {'nombre': 'Bourbon Natural', 'var': ['Bourbon'], 'proc': 'Natural', 'alt': 1900.0, 'punt': 87.0, 'precio': 38000.0, 'cert': []},
        ],
      },
      {
        'marca': 'Finca Los Robles',
        'vendedor': 'María Torres',
        'depto': 'Quindío',
        'municipio': 'Salento',
        'anios': 22,
        'tipoProd': 'Tecnificada',
        'verificado': true,
        'historia':
            'Finca insignia del Eje Cafetero, con puntajes de taza superiores a 88 puntos y '
                'reconocimientos en concursos regionales de calidad.',
        'desc': 'Café de especialidad premium, trazabilidad completa por lote.',
        'lotes': [
          {'nombre': 'Geisha Lavado Premium', 'var': ['Geisha'], 'proc': 'Lavado', 'alt': 1950.0, 'punt': 90.5, 'precio': 85000.0, 'cert': ['Orgánico', 'Denominación de origen']},
          {'nombre': 'Caturra Honey', 'var': ['Caturra'], 'proc': 'Honey', 'alt': 1800.0, 'punt': 87.5, 'precio': 40000.0, 'cert': ['Rainforest Alliance']},
        ],
      },
      {
        'marca': 'Finca El Paraíso',
        'vendedor': 'Luis Fernández',
        'depto': 'Tolima',
        'municipio': 'Líbano',
        'anios': 3,
        'tipoProd': 'Familiar',
        'verificado': false,
        'historia': 'Nueva generación de caficultores enfocados en volumen y precios accesibles.',
        'desc': 'Café comercial ideal para mezclas, buen volumen disponible.',
        'lotes': [
          {'nombre': 'Castillo Lavado', 'var': ['Castillo'], 'proc': 'Lavado', 'alt': 1300.0, 'punt': 81.0, 'precio': 19000.0, 'cert': []},
        ],
      },
      {
        'marca': 'Finca Buena Vista',
        'vendedor': 'Patricia Muñoz',
        'depto': 'Cauca',
        'municipio': 'Inzá',
        'anios': 14,
        'tipoProd': 'Cooperativa',
        'verificado': true,
        'historia':
            'Parte de una red de mujeres caficultoras del macizo caucano, con procesos '
                'experimentales de fermentación anaeróbica.',
        'desc': 'Café con perfiles de taza complejos gracias a la altura y el microclima del Cauca.',
        'lotes': [
          {'nombre': 'Caturra Anaeróbico', 'var': ['Caturra'], 'proc': 'Honey', 'alt': 2000.0, 'punt': 88.0, 'precio': 52000.0, 'cert': ['Orgánico', 'Fair Trade']},
          {'nombre': 'Bourbon Lavado', 'var': ['Bourbon'], 'proc': 'Lavado', 'alt': 1850.0, 'punt': 85.5, 'precio': 34000.0, 'cert': []},
        ],
      },
    ];

    // Ilustraciones de demostración empaquetadas (ver tools/generar_imagenes_demo.py).
    const paisajes = [
      'assets/demo/paisaje_cafetal_verde.jpg',
      'assets/demo/paisaje_cafetal_atardecer.jpg',
      'assets/demo/paisaje_cafetal_neblina.jpg',
    ];
    const detalles = [
      'assets/demo/granos_tostados.jpg',
      'assets/demo/cerezas_cafe.jpg',
      'assets/demo/taza_cafe.jpg',
      'assets/demo/granos_claros.jpg',
      'assets/demo/empaque_cafe.jpg',
      'assets/demo/camas_secado.jpg',
    ];
    int idxVendedor = 0;
    int idxLote = 0;

    for (final d in demo) {
      final vendedorUid = _nuevoId('demo_vendedor_');
      final v = idxVendedor++;
      _usuarios.add(AppUser(
        uid: vendedorUid,
        email: '${(d['vendedor'] as String).split(' ').first.toLowerCase()}@demo.cafe',
        nombre: d['vendedor'] as String,
        rol: UserRole.vendedor,
      ));

      final sellerId = 'perfil_$vendedorUid';
      _vendedores.add(SellerProfile(
        id: sellerId,
        usuarioId: vendedorUid,
        nombreMarca: d['marca'] as String,
        fincaPrincipal: d['marca'] as String,
        descripcion: d['desc'] as String,
        historia: d['historia'] as String,
        aniosProduciendo: d['anios'] as int,
        tipoProduccion: d['tipoProd'] as String,
        region: d['depto'] as String,
        departamento: d['depto'] as String,
        municipio: d['municipio'] as String,
        verificado: d['verificado'] as bool,
        fotoPrincipal: paisajes[v % paisajes.length],
        galeria: [
          paisajes[(v + 1) % paisajes.length],
          detalles[(v + 5) % detalles.length],
          detalles[(v + 1) % detalles.length],
          detalles[(v + 4) % detalles.length],
          paisajes[(v + 2) % paisajes.length],
        ].take(2 + v % 4).toList(),
        calificacionPromedio: 4.0 + (_contador % 10) / 10,
        numOperaciones: 3 + (_contador % 15),
      ));

      for (final loteData in d['lotes'] as List) {
        final j = idxLote++;
        // 1 a 4 fotos por lote, para ejercitar la galería con distintos tamaños.
        final numFotos = 1 + j % 4;
        _lotes.add(CoffeeLot(
          id: _nuevoId('demo_lote_'),
          sellerId: sellerId,
          nombre: loteData['nombre'] as String,
          variedades: List<String>.from(loteData['var'] as List),
          proceso: loteData['proc'] as String,
          tipoCafe: (loteData['punt'] as double) >= 85 ? 'Especial' : 'Comercial',
          altitudMsnm: loteData['alt'] as double,
          puntajeTaza: loteData['punt'] as double,
          cosecha: '2025-2',
          perfilSensorial: TasteProfile(
            notas: (loteData['proc'] == 'Natural')
                ? const ['Frutos rojos', 'Fermentado dulce']
                : (loteData['proc'] == 'Honey')
                    ? const ['Panela', 'Miel']
                    : const ['Cítrico', 'Floral'],
            acidez: 'Media',
            cuerpo: (loteData['proc'] == 'Honey') ? 'Intenso' : 'Medio',
            dulzor: 'Alto',
          ),
          descripcion: 'Lote seleccionado de ${d['marca']}, cosecha 2025-2.',
          precioCOP: loteData['precio'] as double,
          unidad: 'kg',
          cantidadDisponibleKg: 200 + (_contador % 5) * 50,
          pedidoMinimoKg: 5,
          metodosEnvio: const ['Envío nacional', 'Recogida en finca'],
          certificaciones: List<String>.from(loteData['cert'] as List),
          fotos: [for (int k = 0; k < numFotos; k++) detalles[(j + k * 2) % detalles.length]],
          estado: EstadoLote.publicado,
          fechaPublicacion: DateTime.now().subtract(Duration(days: _contador % 20)),
        ));
      }
    }
  }
}
