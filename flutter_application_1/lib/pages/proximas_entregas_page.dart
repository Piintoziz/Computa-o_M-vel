import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../routes/app_routes.dart';

class Encomenda {
  final String nome;
  final String estado;
  final DateTime data;
  final double valor;
  Encomenda({required this.nome, required this.estado, required this.data, required this.valor});
}

class ProximasEntregasPage extends StatefulWidget {
  const ProximasEntregasPage({super.key});

  @override
  State<ProximasEntregasPage> createState() => _ProximasEntregasPageState();
}

class _ProximasEntregasPageState extends State<ProximasEntregasPage> {
  List<Encomenda> encomendas = [
    Encomenda(nome: 'Batatas biológicas', estado: 'Concluída', data: DateTime(2024, 6, 1), valor: 20),
    Encomenda(nome: 'Cenouras frescas', estado: 'Em processamento', data: DateTime(2024, 6, 3), valor: 15),
    Encomenda(nome: 'Tomates', estado: 'Concluída', data: DateTime(2024, 5, 28), valor: 30),
  ];

  String _ordenarPor = 'Data (mais recente)';
  String? _filtroEstado; // null = sem filtro
  String _pesquisa = '';

  List<Encomenda> get _encomendasFiltradas {
    var lista = encomendas;
    if (_filtroEstado != null) {
      lista = lista.where((e) => e.estado == _filtroEstado).toList();
    }
    if (_pesquisa.isNotEmpty) {
      lista = lista.where((e) => e.nome.toLowerCase().contains(_pesquisa.toLowerCase())).toList();
    }
    return lista;
  }

  void _filtrarEncomendas(String? estado) {
    setState(() {
      _filtroEstado = estado;
    });
  }

  void _ordenarEncomendas(String criterio) {
    setState(() {
      _ordenarPor = criterio;
      if (criterio == 'Data (mais recente)') {
        encomendas.sort((a, b) => b.data.compareTo(a.data));
      } else if (criterio == 'Data (mais antiga)') {
        encomendas.sort((a, b) => a.data.compareTo(b.data));
      } else if (criterio == 'Valor (maior)') {
        encomendas.sort((a, b) => b.valor.compareTo(a.valor));
      } else if (criterio == 'Valor (menor)') {
        encomendas.sort((a, b) => a.valor.compareTo(b.valor));
      }
    });
  }

  void _mostrarOpcoesOrdenar() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Data (mais recente)'),
              onTap: () {
                _ordenarEncomendas('Data (mais recente)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Data (mais antiga)'),
              onTap: () {
                _ordenarEncomendas('Data (mais antiga)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Valor (maior)'),
              onTap: () {
                _ordenarEncomendas('Valor (maior)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Valor (menor)'),
              onTap: () {
                _ordenarEncomendas('Valor (menor)');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarOpcoesFiltrar() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              onTap: () {
                _filtrarEncomendas(null);
                Navigator.pop(context);
              },
              selected: _filtroEstado == null,
            ),
            ListTile(
              title: const Text('Concluída'),
              onTap: () {
                _filtrarEncomendas('Concluída');
                Navigator.pop(context);
              },
              selected: _filtroEstado == 'Concluída',
            ),
            ListTile(
              title: const Text('Em processamento'),
              onTap: () {
                _filtrarEncomendas('Em processamento');
                Navigator.pop(context);
              },
              selected: _filtroEstado == 'Em processamento',
            ),
          ],
        );
      },
    );
  }

  void _mostrarPesquisa() {
    String pesquisaTemp = _pesquisa;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Pesquisar encomenda por nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  pesquisaTemp = value;
                  setState(() {
                    _pesquisa = pesquisaTemp;
                  });
                },
                controller: TextEditingController(text: _pesquisa),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _pesquisa = pesquisaTemp;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Aplicar'),
              ),
              if (_pesquisa.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pesquisa = '';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Limpar pesquisa'),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Isto remove a seta!
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        centerTitle: true,
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
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.definicoes);
            },
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
                      onPressed: _mostrarPesquisa,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Consultar'),
                          if (_pesquisa.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.search, size: 18, color: Colors.blue),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _mostrarOpcoesFiltrar,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Filtrar'),
                          if (_filtroEstado != null) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.filter_alt, size: 18, color: Colors.green),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _mostrarOpcoesOrdenar,
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ordenar'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Ordenado por: $_ordenarPor', style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 12),
              ..._encomendasFiltradas.map((e) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: e.estado == 'Concluída' ? const Color(0xFF2E7D5A) : const Color(0xFF3B6B7A), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: e.estado == 'Concluída' ? const Color(0xFF2E7D5A) : const Color(0xFF3B6B7A),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          e.estado == 'Concluída'
                              ? const Text('🏠 ', style: TextStyle(fontSize: 18))
                              : const Icon(Icons.local_shipping, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            e.estado == 'Concluída' ? 'Entrega na morada' : 'Transportadora irá recolher o pedido',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(e.estado == 'Concluída' ? Icons.location_on_outlined : Icons.inventory_2_outlined, size: 18),
                              const SizedBox(width: 4),
                              Text(e.estado == 'Concluída' ? 'Rua Aleixo de Rodrigues' : 'Em preparação (embalamento)'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(e.nome),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (e.estado == 'Concluída') ...[
                                const Icon(Icons.shopping_cart, size: 18),
                                const SizedBox(width: 4),
                                const Text('2 Un.'),
                                const SizedBox(width: 16),
                                const Icon(Icons.euro, size: 18),
                                const SizedBox(width: 4),
                                Text(e.valor.toStringAsFixed(2)),
                              ] else ...[
                                const Text('📅 ', style: TextStyle(fontSize: 18)),
                                const Text('Recolha em 3 dias - até as 10h00'),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(e.data),
                            style: const TextStyle(color: Colors.black45, fontSize: 13),
                          ),
                          Text(
                            e.estado,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 32),
              const Row(
                children: [
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
Image.asset(
                      'assets/images/doubt_icon.png',
                      height: 60,
                    ),                  const SizedBox(height: 8),
                  
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