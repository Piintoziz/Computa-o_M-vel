import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DefinicoesLogisticaPage extends StatefulWidget {
  const DefinicoesLogisticaPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesLogisticaPage> createState() => _DefinicoesLogisticaPageState();
}

class _DefinicoesLogisticaPageState extends State<DefinicoesLogisticaPage> {
  String? _levantamentoSelecionado;
  String? _transportadoraSelecionada;
  String? _entregaLocalSelecionada;
  bool _isLoading = true;

  final List<String> _opcoesLevantamento = ['Entrega ao domicílio', 'Ponto Pick-UP'];
  final List<String> _opcoesTransportadora = ['CTT', 'DPD', 'DHL', 'Outra'];
  final List<String> _opcoesEntregaLocal = ['Entrega própria', 'Serviço de estafetas', 'Não aplicável'];
  
  @override
  void initState() {
    super.initState();
    _carregarDadosLogistica();
  }

  Future<void> _carregarDadosLogistica() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    final ref = FirebaseDatabase.instance.ref('userdata/${user.uid}/logistica');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _levantamentoSelecionado = data['levantamento'];
        _transportadoraSelecionada = data['transportadora'];
        _entregaLocalSelecionada = data['entrega_local'];
      });
    }
    setState(() => _isLoading = false);
  }

  void _salvarAlteracoes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    await FirebaseDatabase.instance.ref('userdata/${user.uid}/logistica').update({
      'levantamento': _levantamentoSelecionado,
      'transportadora': _transportadoraSelecionada,
      'entrega_local': _entregaLocalSelecionada,
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
        title: const Text('Logística',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Gerencie como envia os produtos para os clientes',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDropdownTile('Levantamento', _levantamentoSelecionado, _opcoesLevantamento, (novo) {
                    setState(() => _levantamentoSelecionado = novo);
                  }),
                   _buildDropdownTile('Transportadora', _transportadoraSelecionada, _opcoesTransportadora, (novo) {
                    setState(() => _transportadoraSelecionada = novo);
                  }),
                   _buildDropdownTile('Entrega Local', _entregaLocalSelecionada, _opcoesEntregaLocal, (novo) {
                    setState(() => _entregaLocalSelecionada = novo);
                  }),
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

  Widget _buildDropdownTile(String titulo, String? valor, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        DropdownButtonFormField<String>(
          value: items.contains(valor) ? valor : null,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
