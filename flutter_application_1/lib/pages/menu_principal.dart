import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/app_routes.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF2E7D5A),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 54,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 32),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 32),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.definicoes);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Recomendado para si...',
                style: GoogleFonts.lilitaOne(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF585858),
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
              // Top row with two products
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProductCard(
                    imageUrl: 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc',
                    price: '4.00€/Kg',
                    title: 'Tomates fresco & orgânicos',
                    location: 'Almada',
                    size: 110,
                  ),
                  _ProductCard(
                    imageUrl: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
                    price: '1.500€',
                    title: 'Máquina Agrícola',
                    location: 'Montijo',
                    size: 110,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Bottom row with one product centered
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ProductCard(
                    imageUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
                    price: '2.00€/Kg',
                    title: 'Batatas frescas & orgânicas',
                    location: 'Alentejo',
                    size: 110,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Estes são possíveis Parceiros/Fornecedores',
                      style: GoogleFonts.lilitaOne(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF585858),
                      ),
                    ),
                    Text(
                      'que achamos que poderão ser úteis',
                      style: GoogleFonts.lilitaOne(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF585858),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 3, color: Color(0xFF2E7D5A)),
              const SizedBox(height: 24),
              
              // Alguma Dúvida section
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/doubt_icon.png',
                      height: 60,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alguma Dúvida?',
                      style: GoogleFonts.lilitaOne(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
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
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Entre em contacto connosco!',
                        style: GoogleFonts.lilitaOne(
                          color: const Color(0xFF2E7D5A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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

class _ProductCard extends StatelessWidget {
  final String imageUrl;
  final String price;
  final String title;
  final String location;
  final double size;

  const _ProductCard({
    required this.imageUrl,
    required this.price,
    required this.title,
    required this.location,
    this.size = 110,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2E7D5A), width: 3),
          ),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: GoogleFonts.lilitaOne(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        SizedBox(
          width: size,
          child: Text(
            title,
            style: GoogleFonts.lilitaOne(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          location,
          style: GoogleFonts.lilitaOne(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
