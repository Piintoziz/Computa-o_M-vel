import 'package:flutter/material.dart';

class DefinicoesPagamentoPage extends StatefulWidget {
  const DefinicoesPagamentoPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesPagamentoPage> createState() => _DefinicoesPagamentoPageState();
}

class _DefinicoesPagamentoPageState extends State<DefinicoesPagamentoPage> {
  String iban = 'PT050 0000 0000 0000 0000';
  String paypal = 'exemplo@exemplo.com';
  String mbway = '+351 000000000';

  void _editarCampo(String campo, String valorAtual, Function(String) onConfirmar) {
    TextEditingController controller = TextEditingController(text: valorAtual);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $campo'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirmar(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _salvarAlteracoes() {
    // TODO: salvar dados no Firebase futuramente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados salvos com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        leading: BackButton(color: Colors.white),
        title: const Text('Pagamento',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Escolha como pretende receber os pagamentos',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoTile('IBAN', iban, (novo) => setState(() => iban = novo)),
            _buildInfoTile('PAYPAL', paypal, (novo) => setState(() => paypal = novo)),
            _buildInfoTile('MB Way', mbway, (novo) => setState(() => mbway = novo)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String titulo, String valor, Function(String) onEditar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(valor, style: const TextStyle(fontSize: 14))),
            TextButton(
              onPressed: () => _editarCampo(titulo, valor, onEditar),
              child: const Text('Editar', style: TextStyle(color: Color(0xFF2E7D5A))),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
