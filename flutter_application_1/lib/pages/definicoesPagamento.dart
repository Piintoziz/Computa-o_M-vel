import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DefinicoesPagamentoPage extends StatefulWidget {
  const DefinicoesPagamentoPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesPagamentoPage> createState() => _DefinicoesPagamentoPageState();
}

class _DefinicoesPagamentoPageState extends State<DefinicoesPagamentoPage> {
  final TextEditingController _ibanController = TextEditingController(text: 'A carregar...');
  final TextEditingController _paypalController = TextEditingController(text: 'A carregar...');
  final TextEditingController _mbwayController = TextEditingController(text: 'A carregar...');

  @override
  void initState() {
    super.initState();
    _carregarDadosPagamento();
  }

  Future<void> _carregarDadosPagamento() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('userdata/${user.uid}/pagamento');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _ibanController.text = data['iban'] ?? 'Não definido';
        _paypalController.text = data['paypal'] ?? 'Não definido';
        _mbwayController.text = data['mbway'] ?? 'Não definido';
      });
    } else {
      setState(() {
        _ibanController.text = 'Não definido';
        _paypalController.text = 'Não definido';
        _mbwayController.text = 'Não definido';
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
              setState(() {});
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

    await FirebaseDatabase.instance.ref('userdata/${user.uid}/pagamento').update({
      'iban': _ibanController.text.trim(),
      'paypal': _paypalController.text.trim(),
      'mbway': _mbwayController.text.trim(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados salvos com sucesso!')),
      );
    }
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
            _buildInfoTile('IBAN', _ibanController),
            _buildInfoTile('PAYPAL', _paypalController),
            _buildInfoTile('MB Way', _mbwayController),
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
}
