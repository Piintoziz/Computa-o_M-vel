import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProximasEntregasPage extends StatelessWidget {
  const ProximasEntregasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        title: const Text(
          'Próximas entregas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 30),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Consultar'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Filtrar'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Ordenar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Card 1
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFF2E7D5A), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D5A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: const [
                          Text(
                            '🏠 ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Entrega na morada',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 18),
                              SizedBox(width: 4),
                              Text('Rua Aleixo de Rodrigues'),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text('Batatas biológicas'),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.shopping_cart, size: 18),
                              SizedBox(width: 4),
                              Text('2 Un.'),
                              SizedBox(width: 16),
                              Icon(Icons.euro, size: 18),
                              SizedBox(width: 4),
                              Text('20'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12.0, bottom: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('Concluída', style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Card 2
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFF3B6B7A), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B6B7A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: const [
                          Icon(Icons.local_shipping, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Transportadora irá recolher o pedido',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 18),
                              SizedBox(width: 4),
                              Text('Em preparação (embalamento)'),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '📅 ',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text('Recolha em 3 dias - até as 10h00'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12.0, bottom: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('Em processamento', style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: const [
                  Expanded(
                    child: Divider(
                      color: Color(0xFF2E7D5A),
                      thickness: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  const Icon(Icons.question_answer_outlined, size: 48, color: Colors.black54),
                  const SizedBox(height: 8),
                  Text(
                    'Alguma Dúvida?',
                    style: GoogleFonts.lilitaOne(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black87,
                      shadows: [Shadow(color: Colors.black12, offset: Offset(1,1), blurRadius: 2)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Entre em contacto connosco!',
                    style: TextStyle(color: Color(0xFF2E7D5A), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 