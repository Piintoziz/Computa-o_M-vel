import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DefinicoesNotificacoesPage extends StatefulWidget {
  const DefinicoesNotificacoesPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesNotificacoesPage> createState() => _DefinicoesNotificacoesPageState();
}

class _DefinicoesNotificacoesPageState extends State<DefinicoesNotificacoesPage> {
  bool _novasEncomendas = false;
  bool _descontosAplicados = false;
  bool _campanhasMarketing = false;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('userdata/${user.uid}/notificacoes');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _novasEncomendas = data['novas_encomendas'] ?? false;
        _descontosAplicados = data['descontos_aplicados'] ?? false;
        _campanhasMarketing = data['campanhas_marketing'] ?? false;
      });
    }
  }

  void _salvarPreferencias() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    await FirebaseDatabase.instance.ref('userdata/${user.uid}/notificacoes').update({
      'novas_encomendas': _novasEncomendas,
      'descontos_aplicados': _descontosAplicados,
      'campanhas_marketing': _campanhasMarketing,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferências salvas com sucesso!')),
      );
    }
  }

  Widget _buildSwitchTile(String titulo, String subtitulo, bool valor, Function(bool) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(subtitulo, style: const TextStyle(fontSize: 14))),
            Switch(
              value: valor,
              onChanged: (novo) => setState(() => onChanged(novo)),
              activeColor: const Color(0xFF2E7D5A),
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
        title: const Text('Notificações',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Gerencie as notificações que deseja receber',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile('Novas encomendas', 'Receba notificações sobre novas encomendas', _novasEncomendas,
                (val) => setState(() => _novasEncomendas = val)),
            _buildSwitchTile('Descontos aplicados', 'Receba notificações sobre novos descontos', _descontosAplicados,
                (val) => setState(() => _descontosAplicados = val)),
            _buildSwitchTile('Campanhas de Marketing', 'Receba notificações sobre campanhas', _campanhasMarketing,
                (val) => setState(() => _campanhasMarketing = val)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvarPreferencias,
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
