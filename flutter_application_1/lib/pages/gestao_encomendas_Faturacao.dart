import 'package:flutter/material.dart';

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
  final List<Fatura> _todasFaturas = [
    Fatura(numero: 'Fatura #1402', data: DateTime(2024, 4, 12), cliente: 'Miguel Narciso', valor: 1522),
    Fatura(numero: 'Fatura #1402', data: DateTime(2024, 4, 13), cliente: 'Alexandre Ferreira', valor: 1523),
    Fatura(numero: 'Fatura #1402', data: DateTime(2024, 4, 14), cliente: 'Tiago Dias', valor: 1542),
    Fatura(numero: 'Fatura #1402', data: DateTime(2024, 4, 15), cliente: 'Mariana Pereira', valor: 1512),
  ];

  String? _filtroCliente; // null = sem filtro
  String _ordenarPor = 'Data (mais recente)';

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 16),
            const Text('Faturas Recentes', style: TextStyle(color: Color(0xFF2E7D5A), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: _faturasFiltradas.map((f) => _buildFaturaCard(f.numero, _formatarData(f.data), f.cliente, '€ ${f.valor.toStringAsFixed(2)}')).toList(),
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

  static Widget _buildFaturaCard(String numero, String data, String cliente, String valor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
                  onPressed: () {},
                  child: const Text('Ver fatura'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
