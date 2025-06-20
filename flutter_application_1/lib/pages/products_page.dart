import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
            const SizedBox(height: 2),
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
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.definicoes);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Meus Produtos',
                  style: GoogleFonts.lilitaOne(
                    fontSize: 22,
                    color: const Color(0xFF2E7D5A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Product Presets Grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.7,
                children: const [
                  _ProductPresetCard(
                    image: 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc',
                    name: 'Tomates\nfresco &\norgânicos',
                  ),
                  _ProductPresetCard(
                    image: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
                    name: 'Batatas\nfrescas &\norgânicos',
                  ),
                  _ProductPresetCard(
                    image: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
                    name: 'Máquina\nAgrícola',
                  ),
                  _ProductPresetCard(
                    image: 'https://images.unsplash.com/photo-1506089676908-3592f7389d4d',
                    name: 'Milho\nOrgânico',
                  ),
                  _ProductPresetCard(
                    image: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe',
                    name: 'Cenouras\nOrgânicas',
                  ),
                  _ProductPresetCard(
                    image: 'https://images.unsplash.com/photo-1464983953574-0892a716854b',
                    name: 'Sistema de\nrega\nautomático',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Cabazes',
                  style: GoogleFonts.lilitaOne(
                    fontSize: 22,
                    color: const Color(0xFF2E7D5A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Dropdown
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: 'Produtos',
                        items: const [
                          DropdownMenuItem(value: 'Produtos', child: Text('Produtos')),
                        ],
                        onChanged: (value) {},
                        underline: const SizedBox(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Basket image
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/cabaz_image.png',
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Basket products
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF2E7D5A).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produtos do Cabaz',
                      style: GoogleFonts.lilitaOne(
                        fontSize: 16,
                        color: const Color(0xFF2E7D5A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        _BasketProductChip(
                          image: 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc',
                          name: 'Tomates',
                        ),
                        _BasketProductChip(
                          image: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
                          name: 'Batatas',
                        ),
                        _BasketProductChip(
                          image: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe',
                          name: 'Cenouras',
                        ),
                        _BasketProductChip(
                          image: 'https://images.unsplash.com/photo-1506089676908-3592f7389d4d',
                          name: 'Milho Doce',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D5A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Adicionar ao Cabaz', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF2E7D5A)),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Remover do Cabaz', style: TextStyle(color: Color(0xFF2E7D5A))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 2, color: Color(0xFF2E7D5A)),
              const SizedBox(height: 8),
              // Alguma Dúvida section
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.question_answer, size: 48, color: Colors.black54),
                    const SizedBox(height: 8),
                    Text(
                      'Alguma Dúvida?',
                      style: GoogleFonts.lilitaOne(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.black,
                        shadows: const [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Entre em contacto connosco!',
                      style: GoogleFonts.lilitaOne(
                        color: const Color(0xFF2E7D5A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductPresetCard extends StatelessWidget {
  final String image;
  final String name;
  const _ProductPresetCard({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              image,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.lilitaOne(fontSize: 13, color: Colors.black),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D5A),
              minimumSize: const Size(60, 28),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text('Editar', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _BasketProductChip extends StatelessWidget {
  final String image;
  final String name;
  const _BasketProductChip({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image,
              height: 32,
              width: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: GoogleFonts.lilitaOne(fontSize: 10, color: Colors.black),
          ),
        ],
      ),
    );
  }
} 