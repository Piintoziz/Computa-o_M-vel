import 'package:flutter/material.dart';

class DefinicoesGeralPage extends StatefulWidget {
  const DefinicoesGeralPage({Key? key}) : super(key: key);

  @override
  State<DefinicoesGeralPage> createState() => _DefinicoesGeralPageState();
}

class _DefinicoesGeralPageState extends State<DefinicoesGeralPage> {
  // Dados simulados - serão substituídos pelos dados do Firebase futuramente
  String nomeLoja = 'Loja do Sr.Dinis';
  String descricao = 'Venda de produtos agrícolas e locais';
  String localizacao = 'Rua da agricultura, 10';
  String contacto = '+351 91029384';

  @override
  void initState() {
    super.initState();
    // TODO: carregar dados da loja do Firebase
  }

  void _salvarAlteracoes() {
    // TODO: implementar lógica de salvar alterações no Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alterações salvas com sucesso!')),
    );
  }

  void _editarCampo(String campo, String valorAtual, Function(String) onConfirmar) {
    TextEditingController controller = TextEditingController(text: valorAtual);
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
              onConfirmar(controller.text);
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
            _buildInfoTile('Nome da loja', nomeLoja, (novo) {
              setState(() => nomeLoja = novo);
            }),
            _buildInfoTile('Descrição', descricao, (novo) {
              setState(() => descricao = novo);
            }),
            _buildInfoTile('Localização', localizacao, (novo) {
              setState(() => localizacao = novo);
            }),
            _buildInfoTile('Contacto', contacto, (novo) {
              setState(() => contacto = novo);
            }),
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

  Widget _buildInfoTile(String titulo, String valor, Function(String) onEditar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(valor,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ),
            TextButton(
              onPressed: () => _editarCampo(titulo, valor, onEditar),
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