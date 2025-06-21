import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DefinicoesGeralPage extends StatefulWidget {
  const DefinicoesGeralPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesGeralPage> createState() => _DefinicoesGeralPageState();
}

class _DefinicoesGeralPageState extends State<DefinicoesGeralPage> {
  final TextEditingController _nomeLojaController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDadosDaLoja();
  }

  Future<void> _carregarDadosDaLoja() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('userdata/${user.uid}');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _nomeLojaController.text = data['nome_loja'] ?? 'Defina um nome';
        _descricaoController.text = data['descricao'] ?? '';
        _localizacaoController.text = data['localizacao'] ?? '';
        _contactoController.text = data['contacto'] ?? '';
      });
    }
  }

  void _salvarAlteracoes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseDatabase.instance.ref('userdata/${user.uid}').update({
      'nome_loja': _nomeLojaController.text.trim(),
      'descricao': _descricaoController.text.trim(),
      'localizacao': _localizacaoController.text.trim(),
      'contacto': _contactoController.text.trim(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alterações salvas com sucesso!')),
      );
    }
  }

  void _editarCampo(String campo, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $campo'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Novo $campo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Geral',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Atualize os detalhes da sua loja',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ),  
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildInfoTile('Nome da loja', _nomeLojaController),
            _buildInfoTile('Descrição', _descricaoController),
            _buildInfoTile('Localização', _localizacaoController),
            _buildInfoTile('Contacto', _contactoController),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(fontSize: 16),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String titulo, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(controller.text,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ),
            TextButton(
              onPressed: () => _editarCampo(titulo, controller),
              child: const Text(
                'Editar',
                style: TextStyle(color: Color(0xFF2E7D5A)),
              ),
            )
          ],
        ),
        const Divider(),
      ],
    );
  }
}