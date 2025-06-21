import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DefinicoesContaPage extends StatefulWidget {
  const DefinicoesContaPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesContaPage> createState() => _DefinicoesContaPageState();
}

class _DefinicoesContaPageState extends State<DefinicoesContaPage> {
  final TextEditingController _nomeController = TextEditingController();
  String _email = 'A carregar...';
  bool _administradorCompleto = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosConta();
  }

  Future<void> _carregarDadosConta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref('userdata/${user.uid}');
    final snapshot = await ref.get();

    if (mounted) {
      setState(() {
        _email = user.email ?? 'Sem email';
        if (snapshot.exists && snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          _nomeController.text = data['name'] ?? user.displayName ?? 'Sem nome';
          _administradorCompleto = data['administrador_completo'] ?? false;
        } else {
          _nomeController.text = user.displayName ?? 'Sem nome';
        }
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
              setState(() {}); // Para atualizar a UI imediatamente
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
    
    await FirebaseDatabase.instance.ref('userdata/${user.uid}').update({
      'name': _nomeController.text.trim(),
      'administrador_completo': _administradorCompleto,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados da conta salvos com sucesso!')),
      );
    }
  }

  Widget _buildInfoTile(String titulo, String valor, {bool editavel = true}) {
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
            if (editavel)
              TextButton(
                onPressed: () => _editarCampo(titulo, _nomeController),
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
              value: _administradorCompleto,
              activeColor: const Color(0xFF2E7D5A),
              onChanged: (bool value) {
                setState(() {
                  _administradorCompleto = value;
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
            _buildInfoTile('Nome', _nomeController.text),
            _buildInfoTile('Email', _email, editavel: false),
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
