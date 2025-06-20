import 'package:flutter/material.dart';

class DefinicoesContaPage extends StatefulWidget {
  const DefinicoesContaPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesContaPage> createState() => _DefinicoesContaPageState();
}

class _DefinicoesContaPageState extends State<DefinicoesContaPage> {
  String nome = 'João Silva';
  String email = 'joao@email.com';
  bool administradorCompleto = false;

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
      const SnackBar(content: Text('Dados da conta salvos com sucesso!')),
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
            Expanded(
              child: Text(valor, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ),
            TextButton(
              onPressed: () => _editarCampo(titulo, valor, onEditar),
              child: const Text('Editar', style: TextStyle(color: Color(0xFF2E7D5A))),
            )
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildPermissoesTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Permissões', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text('Administrador completo', style: TextStyle(fontSize: 14)),
            ),
            Switch(
              value: administradorCompleto,
              activeColor: const Color(0xFF2E7D5A),
              onChanged: (bool value) {
                setState(() {
                  administradorCompleto = value;
                });
              },
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
        title: const Text('Conta',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Gerencie a sua conta e permissões',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildInfoTile('Nome', nome, (novo) => setState(() => nome = novo)),
            _buildInfoTile('Email', email, (novo) => setState(() => email = novo)),
            _buildPermissoesTile(),
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
