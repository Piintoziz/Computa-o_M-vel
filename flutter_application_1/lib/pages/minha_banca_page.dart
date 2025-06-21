import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'publicar_anuncio_page.dart'; // Importar a página de publicar anúncio

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
  String? _imagemBancaBase64;
  List<int> _expandedIndexes = [];
  final List<Map<String, dynamic>> _avaliacoesMock = [
    {
      'nome': 'Cliente 1',
      'avatar': null,
      'rating': 5,
      'texto': 'Tudo perfeito e a qualidade é notável! Muito satisfeito',
      'data': 'Há 1 semana',
    },
    {
      'nome': 'Cliente 2',
      'avatar': null,
      'rating': 4,
      'texto': 'Melhorei bastante a qualidade do meu Restaurante!',
      'data': 'Há 2 semanas',
    },
    {
      'nome': 'Cliente 3',
      'avatar': null,
      'rating': 5,
      'texto': 'Tudo perfeito e a qualidade é notável! Muito satisfeito',
      'data': 'Há 1 semana',
    },
  ];

  @override
  void initState() {
    super.initState();
    _carregarAnuncios();
    _carregarNomeLoja();
    _carregarImagemBanca();
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
          'categoria': data['categoria'] ?? '',
          'localizacao': data['localizacao'] ?? '',
          'medida': data['medida'] ?? '',
          'opcaoEntrega': data['opcaoEntrega'] ?? '',
          'quantidadeMinima': data['quantidadeMinima']?.toString() ?? '',
          'telefone': data['telefone'] ?? '',
          'descricao': data['descricao'] ?? '',
        });
      }
    }
    setState(() {
      _anuncios = anuncios;
    });
  }

  Future<void> _carregarImagemBanca() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseDatabase.instance.ref('userdata/${user.uid}/imagem_banca').get();
    if (snapshot.exists && snapshot.value != null) {
      setState(() {
        _imagemBancaBase64 = snapshot.value.toString();
      });
    }
  }

  Future<void> _alterarImagemBanca() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      await FirebaseDatabase.instance.ref('userdata/${user.uid}/imagem_banca').set(base64Image);
      setState(() {
        _imagemBancaBase64 = base64Image;
      });
    }
  }

  void _editarAnuncio(Map<String, dynamic> anuncio) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final anuncioId = anuncio['id'];
    final anuncioRef = FirebaseDatabase.instance.ref('anuncios/$anuncioId');
    final snapshot = await anuncioRef.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    data['id'] = anuncioId; // Garantir que o ID está no mapa

    // Navegar para a PublicarAnuncioPage para edição
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PublicarAnuncioPage(
          anuncioParaEditar: data,
          onPublishSuccess: () {
            Navigator.of(context).pop();
            _carregarAnuncios();
          },
          onBackToIndex: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndexes.contains(index)) {
        _expandedIndexes.remove(index);
      } else {
        _expandedIndexes.add(index);
      }
    });
  }


  Widget _divider() => const Divider(height: 18, thickness: 0.7);

  Widget? _infoRowWithIcon(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.teal[700]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStars(int n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < n ? Icons.star : Icons.star_border,
        color: const Color(0xFF2E7D5A),
        size: 22,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Isto remove a seta!
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        centerTitle: true,
        title: const Text('Minha Banca', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
),
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
                    child: GestureDetector(
                      onTap: _alterarImagemBanca,
                      child: _imagemBancaBase64 != null
                        ? Image.memory(
                            base64Decode(_imagemBancaBase64!),
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: (
                                    anuncio['imagem'] != null && (anuncio['imagem'] as String).startsWith('data:image') == false && (anuncio['imagem'] as String).length > 100
                                  ) ? Image.memory(
                                    base64Decode(anuncio['imagem']),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.network(
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
                                  onPressed: () => _editarAnuncio(anuncio),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Implementar exclusão do anúncio
                                  },
                                ),
                                IconButton(
                                  icon: Icon(_expandedIndexes.contains(i) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                                  onPressed: () => _toggleExpand(i),
                                ),
                              ],
                            ),
                            if (_expandedIndexes.contains(i))
                              Container(
                                margin: const EdgeInsets.only(top: 8, bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoRowWithIcon(Icons.category, 'Categoria', anuncio['categoria']),
                                    _divider(),
                                    _infoRowWithIcon(Icons.location_on, 'Localização', anuncio['localizacao']),
                                    _divider(),
                                    _infoRowWithIcon(Icons.straighten, 'Medida', anuncio['medida']),
                                    _divider(),
                                    _infoRowWithIcon(Icons.person, 'Nome', anuncio['nome']),
                                    _divider(),
                                    _infoRowWithIcon(Icons.local_shipping, 'Opção de Entrega', anuncio['opcaoEntrega']),
                                    _divider(),
                                    _infoRowWithIcon(Icons.euro, 'Preço', anuncio['preco']),
                                    _divider(),
                                    _infoRowWithIcon(Icons.numbers, 'Quantidade Mínima', anuncio['quantidadeMinima'].toString()),
                                    _divider(),
                                    _infoRowWithIcon(Icons.phone, 'Telefone', anuncio['telefone']),
                                    _divider(),
                                    _infoRowWithIcon(Icons.title, 'Título', anuncio['nome']),
                                    _divider(),
                                    _infoRowWithIcon(Icons.description, 'Descrição', anuncio['descricao']),
                                  ].whereType<Widget>().toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ] else ...[
            // Avaliações Tab
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, bottom: 8),
              child: Row(
                children: [
                  const Text('4,0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
                  const SizedBox(width: 8),
                  _buildStars(4),
                  const SizedBox(width: 8),
                  const Text('(70 Avaliações)', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _avaliacoesMock.length + 1,
                itemBuilder: (context, i) {
                  if (i < _avaliacoesMock.length) {
                    final avaliacao = _avaliacoesMock[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, size: 36, color: Colors.grey[700]),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStars(avaliacao['rating']),
                                  const SizedBox(height: 2),
                                  Text(avaliacao['texto'], style: const TextStyle(fontSize: 15)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(avaliacao['data'], style: const TextStyle(color: Colors.black45, fontSize: 13)),
                                      const SizedBox(width: 12),
                                      OutlinedButton(
                                        onPressed: () async {
                                          final TextEditingController _respostaController = TextEditingController();
                                          final result = await showDialog<String>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Responder à avaliação'),
                                                content: TextField(
                                                  controller: _respostaController,
                                                  maxLines: 3,
                                                  decoration: const InputDecoration(hintText: 'Escreva a sua resposta...'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: const Text('Cancelar'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () => Navigator.of(context).pop(_respostaController.text.trim()),
                                                    child: const Text('Enviar'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (result != null && result.isNotEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Resposta enviada com sucesso!')),
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                          minimumSize: const Size(0, 28),
                                          side: const BorderSide(color: Colors.black26),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        child: const Text('Responder', style: TextStyle(fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('▼ Ver mais (68)', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

