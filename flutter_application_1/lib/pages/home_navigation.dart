import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'proximas_entregas_page.dart';
import 'publicar_anuncio_page.dart';
import 'gestão_Encomendas.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({Key? key}) : super(key: key);

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        initialRoute: AppRoutes.home,
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case AppRoutes.home:
              page = const Center(child: Text('Home')); // Placeholder para a página Home
              break;
            case AppRoutes.proximasEntregas:
              page = ProximasEntregasPage();
              break;
            case AppRoutes.publicarAnuncio:
              page = PublicarAnuncioPage(
                onPublishSuccess: () => _navigatorKey.currentState?.pop(),
                onBackToIndex: () => _navigatorKey.currentState?.pop(),
              );
              break;
            case AppRoutes.gestaoEncomendas:
              page = GestaoEncomendasPage(
                onBack: () => _navigatorKey.currentState?.pop(),
              );
              break;
            default:
              page = Center(child: Text('Página não encontrada', style: TextStyle(fontSize: 24)));
          }
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: page,
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D5A),
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    
                    switch (index) {
                      case 0:
                        _navigatorKey.currentState?.pushReplacementNamed(AppRoutes.home);
                        break;
                      case 1:
                        _navigatorKey.currentState?.pushNamed(AppRoutes.proximasEntregas);
                        break;
                      case 2:
                        _navigatorKey.currentState?.pushNamed(AppRoutes.publicarAnuncio);
                        break;
                      case 3:
                        _navigatorKey.currentState?.pushNamed(AppRoutes.gestaoEncomendas);
                        break;
                      case 4:
                        // Página de Ferramentas
                        break;
                    }
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home, size: 32),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_bag, size: 32),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add, size: 36),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person, size: 32),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.build, size: 32),
                      label: '',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 