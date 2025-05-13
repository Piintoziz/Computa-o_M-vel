import 'package:flutter/material.dart';
import 'proximas_entregas_page.dart';
import 'publicar_anuncio_page.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({Key? key}) : super(key: key);

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 1; // Começa na segunda aba (Entregas)
  int _previousIndex = 1;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Center(child: Text('Página Inicial', style: TextStyle(fontSize: 24))),
      ProximasEntregasPage(),
      PublicarAnuncioPage(
        onPublishSuccess: () => setState(() { _selectedIndex = 0; }),
        onBackToIndex: () => setState(() { _selectedIndex = _previousIndex; }),
      ),
      Center(child: Text('Perfil', style: TextStyle(fontSize: 24))),
      Center(child: Text('Ferramentas', style: TextStyle(fontSize: 24))),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _previousIndex = _selectedIndex;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
          onTap: _onItemTapped,
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
    );
  }
} 