import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class GestaoEncomendasEmitirFaturaPage extends StatefulWidget {
  const GestaoEncomendasEmitirFaturaPage({Key? key}) : super(key: key);

  @override
  State<GestaoEncomendasEmitirFaturaPage> createState() => _GestaoEncomendasEmitirFaturaPageState();
}

class _GestaoEncomendasEmitirFaturaPageState extends State<GestaoEncomendasEmitirFaturaPage> {
  String? _tipo;
  DateTime? _dataPagamento;
  String? _metodoPagamento;

  final _tipos = ['Recibo', 'Fatura', 'Nota de Crédito'];
  final _metodos = ['Transferência', 'Cartão', 'Dinheiro', 'MBWay'];

  final _cliente = {
    'nome': 'THE DIVINE COMMUNICATIONS UNIPESSOAL LDA',
    'nif': 'PT 513407789',
    'morada': '',
    'sigla': 'TD',
  };

  final List<Map<String, dynamic>> _artigos = [
    {'nome': 'Maçãs', 'quantidade': 5.0, 'unidade': 'kg', 'preco': 4.0},
  ];

  double get _subtotal => _artigos.fold(0.0, (sum, a) => sum + (a['quantidade'] * a['preco']));
  double get _iva => _subtotal * 0.23;
  double get _total => _subtotal + _iva;

  void _adicionarArtigo() {
    setState(() {
      _artigos.add({'nome': '', 'quantidade': 1.0, 'unidade': 'kg', 'preco': 0.0});
    });
  }

  void _removerArtigo(int index) {
    setState(() {
      _artigos.removeAt(index);
    });
  }

  void _editarArtigo(int index, String campo, dynamic valor) {
    setState(() {
      _artigos[index][campo] = valor;
    });
  }

  Future<void> _selecionarDataPagamento() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataPagamento ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() {
        _dataPagamento = data;
      });
    }
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
            Text('Emitir Fatura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_alt),
                    label: const Text('Filtrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_drop_down),
                    label: const Text('Ordenar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Emissão de Fatura', style: TextStyle(color: Color(0xFF2E7D5A), fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _tipos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _tipo = v),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selecionarDataPagamento,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Data de Pagamento',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  controller: TextEditingController(
                    text: _dataPagamento == null ? '' : '${_dataPagamento!.day}/${_dataPagamento!.month}/${_dataPagamento!.year}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _metodoPagamento,
              decoration: const InputDecoration(
                labelText: 'Método de pagamento',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _metodos.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => _metodoPagamento = v),
            ),
            const SizedBox(height: 18),
            const Text('Faturar para', style: TextStyle(color: Color(0xFF2E7D5A), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: _cliente['nome'],
              decoration: const InputDecoration(
                labelText: 'Nome do Cliente',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (v) => setState(() => _cliente['nome'] = v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _cliente['nif'],
              decoration: const InputDecoration(
                labelText: 'NIF',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (v) => setState(() => _cliente['nif'] = v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _cliente['morada'],
              decoration: const InputDecoration(
                labelText: 'Morada',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (v) => setState(() => _cliente['morada'] = v),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Artigos', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF2E7D5A)),
                  onPressed: _adicionarArtigo,
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _artigos.length,
              itemBuilder: (context, i) {
                final artigo = _artigos[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: TextFormField(
                      initialValue: artigo['nome'],
                      decoration: const InputDecoration(labelText: 'Nome do artigo'),
                      onChanged: (v) => _editarArtigo(i, 'nome', v),
                    ),
                    subtitle: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: artigo['quantidade'].toString(),
                            decoration: const InputDecoration(labelText: 'Qtd'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _editarArtigo(i, 'quantidade', double.tryParse(v) ?? 1.0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: artigo['preco'].toStringAsFixed(2),
                            decoration: const InputDecoration(labelText: 'Preço'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _editarArtigo(i, 'preco', double.tryParse(v) ?? 0.0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(artigo['unidade']),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerArtigo(i),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('€ ${_subtotal.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Iva (23%)'),
                Text('€ ${_iva.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('€ ${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D5A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('É necessário estar autenticado para emitir uma fatura.')),
                    );
                    return;
                  }
                  final faturaRef = FirebaseDatabase.instance.ref('faturas').push();
                  await faturaRef.set({
                    'idFatura': faturaRef.key,
                    'uid': user.uid,
                    'tipo': _tipo,
                    'dataPagamento': _dataPagamento?.toIso8601String(),
                    'metodoPagamento': _metodoPagamento,
                    'nomeCliente': _cliente['nome'],
                    'nif': _cliente['nif'],
                    'moradaEmpresa': _cliente['morada'],
                    'subTotalIva': _iva,
                    'totalFatura': _total,
                    'dataEmissao': DateTime.now().toIso8601String(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fatura emitida e guardada com sucesso!')),
                  );
                  await Future.delayed(const Duration(milliseconds: 800));
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/gestao-encomendas-faturacao');
                  }
                },
                child: const Text('Emitir fatura'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
