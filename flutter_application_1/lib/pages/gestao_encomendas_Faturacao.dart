import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Fatura {
  final String numero;
  final DateTime data;
  final String cliente;
  final double valor;
  Fatura({required this.numero, required this.data, required this.cliente, required this.valor});
}

class GestaoEncomendasFaturacaoPage extends StatefulWidget {
  const GestaoEncomendasFaturacaoPage({Key? key}) : super(key: key);

  @override
  State<GestaoEncomendasFaturacaoPage> createState() => _GestaoEncomendasFaturacaoPageState();
}

class _GestaoEncomendasFaturacaoPageState extends State<GestaoEncomendasFaturacaoPage> {
  List<Fatura> _todasFaturas = [];
  String? _filtroCliente; // null = sem filtro
  String _ordenarPor = 'Data (mais recente)';

  @override
  void initState() {
    super.initState();
    _carregarFaturas();
  }

  Future<void> _carregarFaturas() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseDatabase.instance.ref('faturas').orderByChild('uid').equalTo(user.uid).get(); //Teve de se indexar o campo "uid" para que o get funcionasse
    final List<Fatura> faturas = [];
    for (final child in snapshot.children) {
      final data = child.value as Map<dynamic, dynamic>?;
      if (data != null) {
        faturas.add(Fatura(
          numero: data['nomeCliente'] ?? '',
          data: DateTime.tryParse(data['dataPagamento'] ?? '') ?? DateTime.now(),
          cliente: data['nomeCliente'] ?? '',
          valor: (data['totalFatura'] is num) ? (data['totalFatura'] as num).toDouble() : 0.0,
        ));
      }
    }
    setState(() {
      _todasFaturas = faturas;
    });
  }

  List<Fatura> get _faturasFiltradas {
    var lista = _todasFaturas;
    if (_filtroCliente != null) {
      lista = lista.where((f) => f.cliente == _filtroCliente).toList();
    }
    if (_ordenarPor == 'Data (mais recente)') {
      lista.sort((a, b) => b.data.compareTo(a.data));
    } else if (_ordenarPor == 'Data (mais antiga)') {
      lista.sort((a, b) => a.data.compareTo(b.data));
    } else if (_ordenarPor == 'Valor (maior)') {
      lista.sort((a, b) => b.valor.compareTo(a.valor));
    } else if (_ordenarPor == 'Valor (menor)') {
      lista.sort((a, b) => a.valor.compareTo(b.valor));
    }
    return lista;
  }

  void _filtrarFaturas(String? cliente) {
    setState(() {
      _filtroCliente = cliente;
    });
  }

  void _ordenarFaturas(String criterio) {
    setState(() {
      _ordenarPor = criterio;
    });
  }

  void _mostrarOpcoesFiltrar() {
    final clientes = _todasFaturas.map((f) => f.cliente).toSet().toList();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              onTap: () {
                _filtrarFaturas(null);
                Navigator.pop(context);
              },
              selected: _filtroCliente == null,
            ),
            ...clientes.map((cliente) => ListTile(
              title: Text(cliente),
              onTap: () {
                _filtrarFaturas(cliente);
                Navigator.pop(context);
              },
              selected: _filtroCliente == cliente,
            )),
          ],
        );
      },
    );
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
                _ordenarFaturas('Data (mais recente)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Data (mais antiga)'),
              onTap: () {
                _ordenarFaturas('Data (mais antiga)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Valor (maior)'),
              onTap: () {
                _ordenarFaturas('Valor (maior)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Valor (menor)'),
              onTap: () {
                _ordenarFaturas('Valor (menor)');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarFaturaDialog(Fatura fatura, Map<String, dynamic>? extraData) {
    showDialog(
      context: context,
      builder: (context) {
        String formatarValor(dynamic valor) {
          if (valor is num) {
            return valor.toStringAsFixed(2);
          }
          return valor?.toString() ?? '';
        }
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Fatura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF2E7D5A))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _linhaFatura('Cliente:', fatura.cliente),
                if (extraData != null) ...[
                  _linhaFatura('NIF:', extraData['nif'] ?? ''),
                  _linhaFatura('Morada:', extraData['moradaEmpresa'] ?? ''),
                  _linhaFatura('Tipo:', extraData['tipo'] ?? ''),
                  _linhaFatura('Método de Pagamento:', extraData['metodoPagamento'] ?? ''),
                  _linhaFatura('Preço sem IVA:', '€${formatarValor((extraData['subTotalIva'] is num && extraData['totalFatura'] is num) ? (extraData['totalFatura'] as num) - (extraData['subTotalIva'] as num) : '')}'),
                  _linhaFatura('IVA (23%):', '€${formatarValor(extraData['subTotalIva'])}'),
                  _linhaFatura('Preço com IVA:', '€${formatarValor(extraData['totalFatura'])}'),
                ],
                _linhaFatura('Data:', '${fatura.data.day}/${fatura.data.month}/${fatura.data.year}'),
                _linhaFatura('Valor:', '€${fatura.valor.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                const Divider(),
                const Text('Obrigado pela sua preferência!', style: TextStyle(fontSize: 14, color: Color(0xFF2E7D5A))),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _linhaFatura(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Column(
          children: [
            Text('Gestão Faturação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
            SizedBox(height: 2),
            Text('Tudo num só lugar!', style: TextStyle(fontSize: 15, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _mostrarOpcoesFiltrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Filtrar', style: TextStyle(color: Colors.black)),
                        if (_filtroCliente != null) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.filter_alt, size: 18, color: Colors.green),
                        ],
                      ],
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D5A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Emitir fatura'),
                onPressed: () {
                  Navigator.pushNamed(context, '/gestao-encomendas-emitir-fatura');
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Faturas Recentes', style: TextStyle(color: Color(0xFF2E7D5A), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: _faturasFiltradas.map((f) => _buildFaturaCard(
                  f.numero,
                  _formatarData(f.data),
                  f.cliente,
                  '€ ${f.valor.toStringAsFixed(2)}',
                  onDelete: () async {
                    // Procurar a fatura pelo nome e data para obter o idFatura
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    final snapshot = await FirebaseDatabase.instance.ref('faturas').orderByChild('uid').equalTo(user.uid).get();
                    for (final child in snapshot.children) {
                      final data = child.value as Map<dynamic, dynamic>?;
                      if (data != null && data['nomeCliente'] == f.cliente && (DateTime.tryParse(data['dataPagamento'] ?? '')?.day == f.data.day)) {
                        await FirebaseDatabase.instance.ref('faturas/${child.key}').remove();
                        setState(() {
                          _todasFaturas.remove(f);
                        });
                        break;
                      }
                    }
                  },
                  onView: () async {
                    // Buscar dados extra da fatura para mostrar no dialog
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    final snapshot = await FirebaseDatabase.instance.ref('faturas').orderByChild('uid').equalTo(user.uid).get();
                    Map<String, dynamic>? extraData;
                    for (final child in snapshot.children) {
                      final data = child.value as Map<dynamic, dynamic>?;
                      if (data != null && data['nomeCliente'] == f.cliente && (DateTime.tryParse(data['dataPagamento'] ?? '')?.day == f.data.day)) {
                        extraData = Map<String, dynamic>.from(data);
                        break;
                      }
                    }
                    _mostrarFaturaDialog(f, extraData);
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatarData(DateTime data) {
    return 'Data ${data.day}, ${_mesPorExtenso(data.month)}';
  }

  static String _mesPorExtenso(int mes) {
    const meses = [
      '', 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return meses[mes];
  }

  static Widget _buildFaturaCard(String numero, String data, String cliente, String valor, {required Function() onDelete, required Function() onView}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(numero, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(data, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text(cliente, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(valor, style: const TextStyle(color: Color(0xFF2E7D5A), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D5A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                      ),
                      onPressed: onView,
                      child: const Text('Ver fatura'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Apagar fatura',
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
