import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detalhes_encomenda_page.dart';
import '../models/item_encomenda.dart';
import '../routes/app_routes.dart';


class Encomenda {
  final String id;
  final String cliente;
  final String estadoAtual;
  final DateTime data;
  final List<ItemEncomenda> itens;
  final String metodoPagamento;
  final String enderecoEntrega;
  Encomenda({
    required this.id,
    required this.cliente,
    required this.estadoAtual,
    required this.data,
    required this.itens,
    required this.metodoPagamento,
    required this.enderecoEntrega,
  });
}

class GestaoEncomendasPage extends StatefulWidget {
  final VoidCallback? onBack;
  const GestaoEncomendasPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<GestaoEncomendasPage> createState() => _GestaoEncomendasPageState();
}

class _GestaoEncomendasPageState extends State<GestaoEncomendasPage> {
  final List<Encomenda> _todasEncomendas = [
    Encomenda(
      id: '1048',
      cliente: 'Ana santos',
      estadoAtual: 'Pendente',
      data: DateTime(2025, 3, 17, 15, 2),
      itens: [
        ItemEncomenda(
          nome: 'Maçã Fuji',
          quantidade: '1,5 kg',
          preco: 3.75,
          imagemUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=80&q=80',
        ),
        ItemEncomenda(
          nome: 'Alface Romana',
          quantidade: '5 unidades',
          preco: 5.56,
          imagemUrl: 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=80&q=80',
        ),
        ItemEncomenda(
          nome: 'Cenoura',
          quantidade: '6 unidades',
          preco: 2.40,
          imagemUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=80&q=80',
        ),
        ItemEncomenda(
          nome: 'Ovos',
          quantidade: '6 unidades',
          preco: 2.20,
          imagemUrl: 'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=80&q=80',
        ),
      ],
      metodoPagamento: 'Cartão de Crédito',
      enderecoEntrega: 'Rua do Mercado, 10\n2000-300 Santarém',
    ),
    Encomenda(
      id: '1049',
      cliente: 'Tomás Borges',
      estadoAtual: 'Transporte',
      data: DateTime(2025, 3, 18, 10, 30),
      itens: [
        ItemEncomenda(
          nome: 'Bananas',
          quantidade: '10 kg',
          preco: 12.00,
          imagemUrl: 'https://images.unsplash.com/photo-1574226516831-e1dff420e8e9?auto=format&fit=crop&w=80&q=80',
        ),
        ItemEncomenda(
          nome: 'Laranja',
          quantidade: '8 kg',
          preco: 10.00,
          imagemUrl: 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=80&q=80',
        ),
      ],
      metodoPagamento: 'MBWay',
      enderecoEntrega: 'Av. das Laranjeiras, 50\n1000-200 Lisboa',
    ),
    Encomenda(
      id: '1050',
      cliente: 'Maria Silva',
      estadoAtual: 'Pendente',
      data: DateTime(2025, 3, 19, 9, 0),
      itens: [
        ItemEncomenda(
          nome: 'Batatas',
          quantidade: '5 kg',
          preco: 4.00,
          imagemUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=80&q=80',
        ),
      ],
      metodoPagamento: 'Dinheiro',
      enderecoEntrega: 'Rua Nova, 123\n4000-200 Porto',
    ),
  ];

  final List<String> estados = [
    'Pendente', 'Em preparação', 'Transporte', 'Entregue'
  ];

  String? _filtroEstado; // null = sem filtro
  String _ordenarPor = 'Data (mais recente)';

  List<Encomenda> get _encomendasFiltradas {
    var lista = _todasEncomendas;
    if (_filtroEstado != null) {
      lista = lista.where((e) => e.estadoAtual == _filtroEstado).toList();
    }
    if (_ordenarPor == 'Data (mais recente)') {
      lista.sort((a, b) => b.data.compareTo(a.data));
    } else if (_ordenarPor == 'Data (mais antiga)') {
      lista.sort((a, b) => a.data.compareTo(b.data));
    } else if (_ordenarPor == 'Valor (maior)') {
      lista.sort((a, b) => b.itens.fold<double>(0, (sum, item) => sum + item.preco).compareTo(a.itens.fold<double>(0, (sum, item) => sum + item.preco)));
    } else if (_ordenarPor == 'Valor (menor)') {
      lista.sort((a, b) => a.itens.fold<double>(0, (sum, item) => sum + item.preco).compareTo(b.itens.fold<double>(0, (sum, item) => sum + item.preco)));
    }
    return lista;
  }

  void _filtrarEncomendas(String? estado) {
    setState(() {
      _filtroEstado = estado;
    });
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
            ...estados.map((estado) => ListTile(
              title: Text(estado),
              onTap: () {
                _filtrarEncomendas(estado);
                Navigator.pop(context);
              },
              selected: _filtroEstado == estado,
            )),
          ],
        );
      },
    );
  }

  void _ordenarEncomendas(String criterio) {
    setState(() {
      _ordenarPor = criterio;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Gestão Encomendas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
            SizedBox(height: 2),
            Text('Tudo num só lugar!', style: TextStyle(fontSize: 14, color: Colors.white)),
          ],
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _mostrarOpcoesFiltrar,
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Filtrar', style: TextStyle(color: Colors.black)),
                          if (_filtroEstado != null) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.filter_alt, size: 18, color: Colors.green),
                          ],
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _mostrarOpcoesOrdenar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ordenar', style: TextStyle(color: Colors.black)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Ordenado por: $_ordenarPor', style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 12),
              ..._encomendasFiltradas.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF2E7D5A), width: 4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado ${e.estadoAtual.toLowerCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: (estados.indexOf(e.estadoAtual) + 1) / estados.length,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B6B7A),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: estados.map((estado) => Text(
                            estado,
                            style: TextStyle(
                              fontSize: 13,
                              color: estado == e.estadoAtual ? const Color(0xFF3B6B7A) : Colors.black54,
                              fontWeight: estado == e.estadoAtual ? FontWeight.bold : FontWeight.normal,
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Column(
                              children: [
                                Icon(Icons.person, size: 32, color: Colors.black),
                                SizedBox(height: 12),
                                Icon(Icons.inventory_2, size: 32, color: Colors.black),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.cliente, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                                  const SizedBox(height: 8),
                                  Text(e.itens.map((item) => item.nome).join(", "), style: const TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('€ ${e.itens.fold<double>(0, (sum, item) => sum + item.preco).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalhesEncomendaPage(
                                          cliente: e.cliente,
                                          id: e.id,
                                          estado: e.estadoAtual,
                                          dataPedido: e.data,
                                          itens: e.itens,
                                          metodoPagamento: e.metodoPagamento,
                                          enderecoEntrega: e.enderecoEntrega,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B6B7A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                    elevation: 0,
                                  ),
                                  child: const Text('Ver detalhes', style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(e.data),
                              style: const TextStyle(color: Colors.black45, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
