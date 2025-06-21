import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DefinicoesFaturacaoPage extends StatefulWidget {
  const DefinicoesFaturacaoPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesFaturacaoPage> createState() => _DefinicoesFaturacaoPageState();
}

class _DefinicoesFaturacaoPageState extends State<DefinicoesFaturacaoPage> {
  final TextEditingController _nifController = TextEditingController(text: 'A carregar...');
  final TextEditingController _moradaController = TextEditingController(text: 'A carregar...');

  @override
  void initState() {
    super.initState();
    _carregarDadosFaturacao();
  }

  Future<void> _carregarDadosFaturacao() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('userdata/${user.uid}/faturacao');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _nifController.text = data['nif'] ?? 'Não definido';
        _moradaController.text = data['morada'] ?? 'Não definida';
      });
    } else {
      setState(() {
        _nifController.text = 'Não definido';
        _moradaController.text = 'Não definida';
      });
    }
  }

  void _editarCampo(String campo, TextEditingController controller) {
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
              setState((){});
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _salvarAlteracoes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    await FirebaseDatabase.instance.ref('userdata/${user.uid}/faturacao').update({
      'nif': _nifController.text.trim(),
      'morada': _moradaController.text.trim(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados de faturação salvos com sucesso!')),
      );
    }
  }

  Widget _buildInfoTile(String titulo, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(controller.text, style: const TextStyle(fontSize: 14))),
            TextButton(
              onPressed: () => _editarCampo(titulo, controller),
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
            _buildInfoTile('NIF', _nifController),
            _buildInfoTile('Morada de faturação', _moradaController),
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
