import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MinhaBancaPage extends StatefulWidget {
  const MinhaBancaPage({Key? key}) : super(key: key);

  @override
  State<MinhaBancaPage> createState() => _MinhaBancaPageState();
}

class _MinhaBancaPageState extends State<MinhaBancaPage> {
  int _selectedTab = 0; // 0: Banca, 1: Avaliações
  List<Map<String, dynamic>> _anuncios = [];
  final TextEditingController _shopNameController = TextEditingController();
  String _shopName = 'Nome da Loja'; // Default value

  @override
  void initState() {
    super.initState();
    _carregarAnuncios();
    _carregarNomeLoja();
  }

  Future<void> _carregarNomeLoja() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseDatabase.instance.ref('userdata/${user.uid}/nome_loja').get();
    if (snapshot.exists && snapshot.value != null) {
      setState(() {
        _shopName = snapshot.value.toString();
        _shopNameController.text = _shopName;
      });
    }
  }

  Future<void> _updateShopName(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseDatabase.instance.ref('userdata/${user.uid}/nome_loja').set(newName);
    setState(() {
      _shopName = newName;
    });
  }

  Future<void> _carregarAnuncios() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseDatabase.instance.ref('anuncios').orderByChild('uid').equalTo(user.uid).get();
    final List<Map<String, dynamic>> anuncios = [];
    for (final child in snapshot.children) {
      final data = child.value as Map<dynamic, dynamic>?;
      if (data != null) {
        anuncios.add({
          'imagem': (data['fotos'] is List && (data['fotos'] as List).isNotEmpty) ? (data['fotos'] as List).first : 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
          'nome': data['titulo'] ?? '',
          'preco': data['preco'] != null ? '${data['preco']}€/kg' : 'x€/kg',
          'id': child.key,
        });
      }
    }
    setState(() {
      _anuncios = anuncios;
    });
  }

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
        title: const Text('Minha Banca', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Column(
                    children: [
                      Text('Banca', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: _selectedTab == 0 ? Colors.black : Colors.black54,
                        decoration: _selectedTab == 0 ? TextDecoration.underline : null,
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 8), // Smaller gap
                const Text('|', style: TextStyle(fontSize: 26, color: Colors.black54)), // Separator
                const SizedBox(width: 8), // Smaller gap
                GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Column(
                    children: [
                      Text('Avaliações', style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 26,
                        color: _selectedTab == 1 ? Colors.black : Colors.black54,
                        decoration: _selectedTab == 1 ? TextDecoration.underline : null,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_selectedTab == 0) ...[
            // Banca Tab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(_shopName, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _shopNameController.text = _shopName; // Populate with current name
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Editar Nome da Loja'),
                            content: TextField(
                              controller: _shopNameController,
                              decoration: const InputDecoration(hintText: 'Novo nome da loja'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _updateShopName(_shopNameController.text.trim());
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Guardar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Implementar ver mais detalhes
                    },
                    icon: const Icon(Icons.keyboard_arrow_down),
                    label: const Text('Ver mais detalhes'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Anúncios Publicados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _anuncios.isEmpty
                ? const Center(child: Text('Nenhum anúncio publicado ainda.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _anuncios.length,
                    itemBuilder: (context, i) {
                      final anuncio = _anuncios[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                anuncio['imagem'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(anuncio['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(anuncio['preco'], style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black54),
                              onPressed: () {
                                // Implementar edição do anúncio
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Implementar exclusão do anúncio
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ] else ...[
            // Avaliações Tab (placeholder)
            const Expanded(
              child: Center(
                child: Text('Avaliações do produtor em breve!', style: TextStyle(fontSize: 16, color: Colors.black54)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

