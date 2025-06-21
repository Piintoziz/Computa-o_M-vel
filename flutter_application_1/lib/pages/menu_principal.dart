import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import '../routes/app_routes.dart';
import '../widgets/shake_detector_mixin.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with ShakeDetectorMixin {
  List<Map<String, dynamic>> _anuncios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAnuncios();
  }

  Future<void> _carregarAnuncios() async {
    try {
      // 1. Vai buscar TODOS os anúncios, em vez de apenas os 3 primeiros
      final ref = FirebaseDatabase.instance.ref('anuncios');
      final snapshot = await ref.get();
      final List<Map<String, dynamic>> todosAnuncios = [];

      if (snapshot.exists && snapshot.value != null) {
        if (snapshot.value is Map) {
          final data = Map<Object?, Object?>.from(snapshot.value as Map);
          for (var entry in data.entries) {
            final key = entry.key;
            final value = entry.value;

            if (key is String && value is Map) {
              final anuncioData = Map<String, dynamic>.from(value);
              final fotos = anuncioData['fotos'];
              String? imagemUrl;
              if (fotos is List && fotos.isNotEmpty && fotos[0] is String) {
                imagemUrl = fotos[0];
              }

              todosAnuncios.add({
                'id': key,
                'titulo': anuncioData['titulo']?.toString() ?? 'Sem título',
                'preco': (anuncioData['preco'] as num?)?.toDouble() ?? 0.0,
                'medida': anuncioData['medida']?.toString() ?? '',
                'localizacao': anuncioData['localizacao']?.toString() ?? 'Sem localização',
                'imagem': imagemUrl,
              });
            }
          }
        } else {
          print("ALERTA: Os dados dos anúncios não vieram no formato esperado de Mapa.");
        }
      }

      // 2. Baralha a lista e seleciona 3 aleatoriamente
      todosAnuncios.shuffle();
      final anunciosAleatorios = todosAnuncios.take(3).toList();

      if (mounted) {
        setState(() {
          _anuncios = anunciosAleatorios;
          _isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      print('Erro ao carregar anúncios: $e');
      print('Stacktrace: $stacktrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
              _buildRecomendados(),
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

  Widget _buildRecomendados() {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (_anuncios.isEmpty) {
      return const Center(child: Text('De momento, não há anúncios para recomendar.'));
    }

    // Formatar o preço para exibição
    String formatPrice(Map<String, dynamic> anuncio) {
      final price = anuncio['preco'];
      final medida = anuncio['medida'];
      if (medida != null && medida.isNotEmpty && medida != 'Unidade') {
        return '${price.toStringAsFixed(2)}€/$medida';
      }
      return '${price.toStringAsFixed(2)}€';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_anuncios.length > 0)
              _ProductCard(
                imageUrl: _anuncios[0]['imagem'],
                price: formatPrice(_anuncios[0]),
                title: _anuncios[0]['titulo'],
                location: _anuncios[0]['localizacao'],
                size: 110,
              ),
            if (_anuncios.length > 1)
               _ProductCard(
                imageUrl: _anuncios[1]['imagem'],
                price: formatPrice(_anuncios[1]),
                title: _anuncios[1]['titulo'],
                location: _anuncios[1]['localizacao'],
                size: 110,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             if (_anuncios.length > 2)
              _ProductCard(
                imageUrl: _anuncios[2]['imagem'],
                price: formatPrice(_anuncios[2]),
                title: _anuncios[2]['titulo'],
                location: _anuncios[2]['localizacao'],
                size: 110,
              ),
          ],
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String? imageUrl;
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
    Widget imageWidget;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(imageUrl!);
        imageWidget = Image.memory(decodedBytes, fit: BoxFit.cover, gaplessPlayback: true);
      } catch (e) {
        print("Erro ao descodificar imagem: $e");
        imageWidget = const Icon(Icons.broken_image, color: Colors.grey, size: 48);
      }
    } else {
      imageWidget = const Icon(Icons.image_not_supported, color: Colors.grey, size: 48);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2E7D5A), width: 3),
            color: Colors.grey[200],
          ),
          child: imageWidget,
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
