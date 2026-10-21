import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/home_tab_notifier.dart';
import '../../services/session_provider.dart';
import '../discover/discover_screen.dart';
import '../requests/my_requests_screen.dart';
import '../requests/received_requests_screen.dart';
import '../saved/saved_screen.dart';
import '../seller/my_coffee_lots_screen.dart';
import '../profile/my_profile_screen.dart';

/// Contenedor con navegación inferior — comprador y vendedor ven pestañas
/// distintas, sin accesos duplicados entre AppBar y navegación inferior:
///   Comprador: Descubrir · Solicitudes · Guardados · Cuenta
///   Vendedor:  Mi catálogo · Solicitudes · Cuenta
///
/// El índice activo vive en [HomeTabNotifier] (no en un State local) para que
/// una acción de otra pantalla (p. ej. el snackbar "Ver solicitudes" tras
/// enviar una solicitud) pueda cambiar de pestaña sin navegar a una ruta
/// nueva ni duplicar la navegación existente.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final esVendedor = context.watch<SessionProvider>().esVendedor;
    final tabs = context.watch<HomeTabNotifier>();

    final paginas = esVendedor
        ? const [MyCoffeeLotsScreen(), ReceivedRequestsScreen(), MyProfileScreen()]
        : const [DiscoverScreen(), MyRequestsScreen(), SavedScreen(), MyProfileScreen()];

    final items = esVendedor
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Mi catálogo'),
            BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), activeIcon: Icon(Icons.inbox), label: 'Solicitudes'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cuenta'),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.travel_explore_outlined), activeIcon: Icon(Icons.travel_explore), label: 'Descubrir'),
            BottomNavigationBarItem(icon: Icon(Icons.outbox_outlined), activeIcon: Icon(Icons.outbox), label: 'Solicitudes'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), activeIcon: Icon(Icons.bookmark), label: 'Guardados'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cuenta'),
          ];

    final indice = tabs.indice >= paginas.length ? 0 : tabs.indice;

    return Scaffold(
      body: IndexedStack(index: indice, children: paginas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indice,
        onTap: tabs.ir,
        items: items,
      ),
    );
  }
}
