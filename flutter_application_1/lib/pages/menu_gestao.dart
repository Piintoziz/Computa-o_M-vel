import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuGestao extends StatelessWidget {
  const MenuGestao({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const _GestaoDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Gestão',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Tudo num só lugar!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visão Geral da sua Banca
            Center(
              child: Text(
                'Visão Geral da sua Banca',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D5A),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D5A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _OverviewItem(title: 'Vendas', value: '10'),
                        _OverviewItem(title: 'Encomendas\nPendentes', value: '3'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _OverviewItem(title: 'Produtos', value: '25'),
                        _OverviewItem(title: 'Avaliações', value: '7'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Próximos Passos
            Text(
              'Próximos Passos',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D5A),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 10, color: Color(0xFF2E7D5A)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Faça o setup da sua banca!',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: const Color(0xFF585858),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: SizedBox(
                width: 180,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF184D2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Ir para a Minha Banca',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 10, color: Color(0xFF2E7D5A)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Publique o seu primeiro anúncio',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: const Color(0xFF585858),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: SizedBox(
                width: 180,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF184D2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Criar novo anúncio',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Divider(thickness: 3, color: Color(0xFF2E7D5A)),
            // Bottom Doubt Section
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/doubt_icon.png',
                    height: 72,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Alguma Dúvida?',
                    style: GoogleFonts.lilitaOne(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      shadows: const [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Entre em contacto connosco!',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2E7D5A),
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GestaoDrawer extends StatelessWidget {
  const _GestaoDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF2E7D5A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 32),
            _DrawerNavItem(
              label: 'Página Inicial',
              icon: Icons.home,
              selected: true,
            ),
            _DrawerNavItem(
              label: 'Encomendas',
              icon: Icons.shopping_cart,
              selected: false,
              subItems: const [
                'Faturação',
                'Compras Abandonadas',
              ],
            ),
            _DrawerNavItem(
              label: 'Produtos',
              icon: Icons.local_grocery_store,
              selected: false,
            ),
            _DrawerNavItem(
              label: 'Clientes',
              icon: Icons.people,
              selected: false,
            ),
            _DrawerNavItem(
              label: 'Análise de Dados',
              icon: Icons.bar_chart,
              selected: false,
              subItems: const [
                'Finanças',
                'Canais de Vendas',
              ],
            ),
            _DrawerNavItem(
              label: 'Anúncios',
              icon: Icons.ondemand_video,
              selected: false,
            ),
            _DrawerNavItem(
              label: 'Destacar Anúncios',
              icon: Icons.star,
              selected: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final List<String>? subItems;

  const _DrawerNavItem({
    required this.label,
    required this.icon,
    this.selected = false,
    this.subItems,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2E7D5A), width: 2),
                )
              : null,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: selected ? const Color(0xFF2E7D5A) : Colors.white, size: 22),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: selected ? const Color(0xFF2E7D5A) : Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        if (subItems != null)
          Padding(
            padding: const EdgeInsets.only(left: 36.0, top: 2, bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subItems!
                  .map((s) => Text(
                        s,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String title;
  final String value;

  const _OverviewItem({required this.title, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF053D02),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
