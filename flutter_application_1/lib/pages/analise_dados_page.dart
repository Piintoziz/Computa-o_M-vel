import 'package:flutter/material.dart';

class AnaliseDadosPage extends StatelessWidget {
  // Hardcoded data (to be replaced by DB later)
  final int visitas = 1542;
  final String epicentro = 'Lisboa';
  final Map<String, int> canalVendas = {
    'Domicilio': 1522,
    'Recolha': 1123,
    'Transporte': 841,
  };
  final Map<String, int> principaisProdutos = {
    'Cenouras': 244,
    'Trigo': 194,
    'Milho': 177,
    'Alho': 134,
  };
  final int receita = 2433;
  final int lucro = 784;

  AnaliseDadosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Análise de dados',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                'Análise de dados',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 18),
              // Relatórios Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Icon(Icons.insert_chart_outlined, size: 38, color: primaryColor),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Relatórios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text('Gere relatórios detalhados num determinado intervalo de tempo',
                              style: TextStyle(fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Visitas à banca Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Icon(Icons.storefront, size: 38, color: primaryColor),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Visitas á banca', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text('Numero de visitas: $visitas\nEpicentro das vendas: $epicentro',
                              style: TextStyle(fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Por Canal de Vendas Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Por Canal de Vendas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                      const SizedBox(height: 10),
                      ...canalVendas.entries.map((entry) {
                        double percent = entry.value / canalVendas.values.first;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              SizedBox(width: 90, child: Text(entry.key, style: TextStyle(fontSize: 15))),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text('€ ${entry.value}', style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Principais Produtos Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Principais Produtos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                      const SizedBox(height: 10),
                      ...principaisProdutos.entries.map((entry) {
                        double percent = entry.value / principaisProdutos.values.first;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              SizedBox(width: 90, child: Text(entry.key, style: TextStyle(fontSize: 15))),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text('€ ${entry.value}', style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      Text('Finanças', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Receita', style: TextStyle(fontSize: 16)),
                              Text('Lucro', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('€$receita', style: TextStyle(fontSize: 16)),
                              Text('€$lucro', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 