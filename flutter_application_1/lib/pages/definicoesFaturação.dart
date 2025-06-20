import 'package:flutter/material.dart';

class DefinicoesFaturacaoPage extends StatefulWidget {
  const DefinicoesFaturacaoPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesFaturacaoPage> createState() => _DefinicoesFaturacaoPageState();
}

class _DefinicoesFaturacaoPageState extends State<DefinicoesFaturacaoPage> {
  String nif = '123456789';
  String morada = 'Rua Exemplo, nº 123, Lisboa';

  void _editarCampo(String campo, String valorAtual, Function(String) onConfirmar) {
    final controller = TextEditingController(text: valorAtual);
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
    // TODO: guardar dados no Firebase futuramente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados de faturação salvos com sucesso!')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        leading: BackButton(color: Colors.white),
        title: const Text('Faturação',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Gerencie toda a sua faturação',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoTile('NIF', nif, (novo) => setState(() => nif = novo)),
            _buildInfoTile('Morada de faturação', morada, (novo) => setState(() => morada = novo)),
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
}
