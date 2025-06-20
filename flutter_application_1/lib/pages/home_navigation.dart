import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/definicoesConta.dart';
import 'package:flutter_application_1/pages/definicoesFatura%C3%A7%C3%A3o.dart';
import 'package:flutter_application_1/pages/definicoesGeral.dart';
import 'package:flutter_application_1/pages/definicoesLogistica.dart';
import 'package:flutter_application_1/pages/definicoesNotifica%C3%A7%C3%B5es.dart';
import 'package:flutter_application_1/pages/definicoesPagamento.dart';
import '../routes/app_routes.dart';
import 'proximas_entregas_page.dart';
import 'publicar_anuncio_page.dart';
import 'gestao_Encomendas.dart';
import 'menu_gestao.dart';
import 'menu_principal.dart';
import 'minha_banca_page.dart';
import 'definicoes.dart';

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
        initialRoute: AppRoutes.menuPrincipal,
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case AppRoutes.menuPrincipal:
              page = const MainMenu();
              break;
            case AppRoutes.proximasEntregas:
              page = const ProximasEntregasPage();
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
            case AppRoutes.menuGestao:
              page = const MenuGestao();
              break;
            case AppRoutes.minhaBanca:
              page = const MinhaBancaPage();
              break;
            case AppRoutes.definicoes:
              page = const DefinicoesPage();
              break;
            case AppRoutes.definicoesConta:
              page = const DefinicoesContaPage();
              break;
            case AppRoutes.definicoesNotificacoes:
              page = const DefinicoesNotificacoesPage();
              break;
            case AppRoutes.definicoesFaturacao:
              page = const DefinicoesFaturacaoPage();
              break;
            case AppRoutes.definicoesGeral:
              page = const DefinicoesGeralPage();
              break;
            case AppRoutes.definicoesLogistica:
              page = const DefinicoesLogisticaPage();
              break;
            case AppRoutes.definicoesPagamento:
              page = const DefinicoesPagamentoPage();
              break;
            default:
              page = const Center(child: Text('Página não encontrada', style: TextStyle(fontSize: 24)));
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
                        _navigatorKey.currentState?.pushReplacementNamed(AppRoutes.menuPrincipal);
                        break;
                      case 1:
                        _navigatorKey.currentState?.pushNamed(AppRoutes.proximasEntregas);
                        break;
                      case 2:
                        _navigatorKey.currentState?.pushNamed(AppRoutes.publicarAnuncio);
                        break;
                      case 3:
                        _navigatorKey.currentState?.pushNamed(AppRoutes.minhaBanca);                        
                        break;
                      case 4:
                        _navigatorKey.currentState?.pushNamed(AppRoutes.menuGestao);
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