import 'package:flutter/material.dart';
import '../routes/app_routes.dart';


class GestaoEncomendasComprasAbandonadasPage extends StatefulWidget {
  const GestaoEncomendasComprasAbandonadasPage({Key? key}) : super(key: key);

  @override
  State<GestaoEncomendasComprasAbandonadasPage> createState() => _GestaoEncomendasComprasAbandonadasPageState();
}

class _GestaoEncomendasComprasAbandonadasPageState extends State<GestaoEncomendasComprasAbandonadasPage> {
  final List<Map<String, dynamic>> _comprasAbandonadas = [
    {
      'nome': 'João Sousa',
      'produtos': 'Maçãs 10kg, tomates 5kg',
      'ultimoAcesso': DateTime(2025, 4, 22),
      'avatar': 'JS',
    },
    {
      'nome': 'João Sousa',
      'produtos': 'Maçãs 10kg, tomates 5kg',
      'ultimoAcesso': DateTime(2025, 4, 22),
      'avatar': 'JS',
    },
    {
      'nome': 'Daniel Maria',
      'produtos': 'Bananas 10kg, Morangos 5kg',
      'ultimoAcesso': DateTime(2025, 4, 22),
      'avatar': 'DM',
    },
    {
      'nome': 'Guilherme Leça',
      'produtos': 'Maçãs 10kg, tomates 5kg',
      'ultimoAcesso': DateTime(2025, 4, 22),
      'avatar': 'GL',
    },
    {
      'nome': 'Guilherme Leça',
      'produtos': 'Maçãs 10kg, tomates 5kg',
      'ultimoAcesso': DateTime(2025, 4, 22),
      'avatar': 'GL',
    },
  ];

  final String _ordenarPor = 'Ordenar';
  final String _filtro = 'Filtrar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Column(
          children: [
            Text('Gestão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
            SizedBox(height: 2),
            Text('Tudo num só lugar!', style: TextStyle(fontSize: 15, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.definicoes);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filtro,
                    items: [const DropdownMenuItem(value: 'Filtrar', child: Text('Filtrar'))],
                    onChanged: (v) {},
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _ordenarPor,
                    items: [const DropdownMenuItem(value: 'Ordenar', child: Text('Ordenar'))],
                    onChanged: (v) {},
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Compras Abandonadas', style: TextStyle(color: Color(0xFF2E7D5A), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _comprasAbandonadas.length,
                itemBuilder: (context, i) {
                  final compra = _comprasAbandonadas[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF2E7D5A),
                            child: Text(compra['avatar'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(compra['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(compra['produtos'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                const Text('Ultimo acesso:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                Text('${compra['ultimoAcesso'].day} abril ${compra['ultimoAcesso'].year}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              _mostrarLembreteEnviado(context, compra['nome']);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D5A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                            ),
                            child: const Text('Enviar Lembrete'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarLembreteEnviado(BuildContext context, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Lembrete Enviado!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D5A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D5A), size: 48),
            const SizedBox(height: 12),
            Text('Foi enviado um lembrete para o cliente $nome com sucesso!', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
