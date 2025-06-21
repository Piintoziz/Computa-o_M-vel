import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:flutter_application_1/pages/products_page_criar_editar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> _meusProdutos = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _cabazAtual = [];
  String? _produtoSelecionadoId;
  final _cabazNameController = TextEditingController();
  List<Map<String, dynamic>> _meusCabazes = [];
  bool _isLoadingCabazes = true;
  int _openCabazPanelIndex = -1;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _cabazNameController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final produtos = await _carregarProdutos();
    await _carregarCabazes(produtos);
  }

  Future<List<Map<String, dynamic>>> _carregarProdutos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return [];
    }

    try {
      final ref = FirebaseDatabase.instance.ref('produtos').orderByChild('uid').equalTo(user.uid);
      final snapshot = await ref.get();
      final List<Map<String, dynamic>> produtosTemp = [];

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              final produtoData = Map<String, dynamic>.from(value);
              produtoData['id'] = key;
              produtosTemp.add(produtoData);
            }
          });
        }
      }
      
      if (mounted) {
        setState(() {
          _meusProdutos = produtosTemp;
          _isLoading = false;
        });
      }
      return produtosTemp;
    } catch (e) {
      print("Erro ao carregar produtos: $e");
      if (mounted) setState(() => _isLoading = false);
      return [];
    }
  }

  Future<void> _carregarCabazes(List<Map<String, dynamic>> produtos) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingCabazes = false);
      return;
    }

    setState(() => _isLoadingCabazes = true);
    try {
      final ref = FirebaseDatabase.instance.ref('cabazes').orderByChild('uid').equalTo(user.uid);
      final snapshot = await ref.get();
      final List<Map<String, dynamic>> cabazesTemp = [];

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              final cabazData = Map<String, dynamic>.from(value);
              cabazData['id'] = key;
              
              // Mapear IDs de produtos para os dados completos dos produtos
              if (cabazData['produtos'] is List) {
                List<Map<String, dynamic>> produtosDetalhados = [];
                for (var produtoId in cabazData['produtos']) {
                  final produto = produtos.firstWhere(
                    (p) => p['id'] == produtoId,
                    orElse: () => {}, // Retorna mapa vazio se não encontrar
                  );
                  if (produto.isNotEmpty) {
                    produtosDetalhados.add(produto);
                  }
                }
                cabazData['produtosDetalhados'] = produtosDetalhados;
              }
              cabazesTemp.add(cabazData);
            }
          });
        }
      }
      
      if (mounted) {
        setState(() {
          _meusCabazes = cabazesTemp;
          _isLoadingCabazes = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar cabazes: $e");
      if (mounted) setState(() => _isLoadingCabazes = false);
    }
  }

  Future<void> _guardarCabaz() async {
    if (_cabazAtual.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('O cabaz está vazio! Adicione produtos antes de guardar.'), backgroundColor: Colors.red));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utilizador não autenticado.')));
      return;
    }

    final nomeCabaz = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nome do Cabaz'),
        content: TextField(
          controller: _cabazNameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex: Cabaz de Verão'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (_cabazNameController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(_cabazNameController.text.trim());
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (nomeCabaz != null && nomeCabaz.isNotEmpty) {
      try {
        final List<String> idProdutos = _cabazAtual.map((p) => p['id'] as String).toList();
        
        final cabazData = {
          'uid': user.uid,
          'nome': nomeCabaz,
          'produtos': idProdutos,
          'timestamp': ServerValue.timestamp,
        };

        await FirebaseDatabase.instance.ref('cabazes').push().set(cabazData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cabaz "$nomeCabaz" guardado com sucesso!'), backgroundColor: const Color(0xFF2E7D5A))
          );
          setState(() {
            _cabazAtual.clear();
            _cabazNameController.clear();
          });
          _carregarCabazes(_meusProdutos);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao guardar o cabaz: $e')));
        }
      }
    }
    // Recarregar os produtos após voltar da página de edição/criação
    setState(() => _isLoading = true);
    _carregarDados();
  }

  void _adicionarAoCabaz() {
    if (_produtoSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione um produto para adicionar.'), backgroundColor: Colors.orange));
      return;
    }

    final produtoJaNoCabaz = _cabazAtual.any((p) => p['id'] == _produtoSelecionadoId);
    if (produtoJaNoCabaz) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este produto já está no cabaz.'), backgroundColor: Colors.orange));
      return;
    }

    final produtoParaAdicionar = _meusProdutos.firstWhere((p) => p['id'] == _produtoSelecionadoId);
    setState(() {
      _cabazAtual.add(produtoParaAdicionar);
    });
  }

  void _limparCabaz() {
    setState(() {
      _cabazAtual.clear();
    });
  }

  void _navigateToCreateEditPage({Map<String, dynamic>? produto}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductsPageCriarEditar(produtoParaEditar: produto)),
    );
    // Recarregar os produtos após voltar da página de edição/criação
    setState(() => _isLoading = true);
    _carregarDados();
  }

  Future<void> _apagarProduto(String produtoId) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem a certeza que quer apagar este produto? Esta ação não pode ser revertida.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        await FirebaseDatabase.instance.ref('produtos/$produtoId').remove();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto apagado com sucesso!'), backgroundColor: Colors.green),
          );
          _carregarDados(); // Recarregar a lista
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao apagar produto: $e')));
        }
      }
    }
  }

  Future<void> _apagarCabaz(String cabazId) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem a certeza que quer apagar este cabaz?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        await FirebaseDatabase.instance.ref('cabazes/$cabazId').remove();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cabaz apagado com sucesso!'), backgroundColor: Colors.green),
          );
          _carregarCabazes(_meusProdutos); // Recarrega apenas a lista de cabazes
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao apagar cabaz: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Gestão',
              style: GoogleFonts.poppins(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Tudo num só lugar!',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.definicoes),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _navigateToCreateEditPage,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Criar Novo Produto', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D5A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Meus Produtos',
                style: GoogleFonts.lilitaOne(
                  fontSize: 22,
                  color: const Color(0xFF2E7D5A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildProductsGrid(),
              const SizedBox(height: 24),
              Text(
                'Cabazes',
                style: GoogleFonts.lilitaOne(
                  fontSize: 22,
                  color: const Color(0xFF2E7D5A),
                   fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _produtoSelecionadoId,
                            hint: const Text("Selecione..."),
                            items: _meusProdutos.map<DropdownMenuItem<String>>((produto) {
                              return DropdownMenuItem<String>(
                                value: produto['id'],
                                child: Text(
                                  produto['nome'] ?? 'Produto sem nome',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _produtoSelecionadoId = value;
                              });
                            },
                            underline: const SizedBox(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.asset(
                          'assets/images/cabaz_image.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D5A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Produtos do Cabaz',
                            style: GoogleFonts.lilitaOne(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _cabazAtual.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final produto = _cabazAtual[index];
                              return _BasketProductChip(
                                image: produto['imagem'],
                                name: produto['nome'] ?? 'Sem nome',
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _CabazButton(text: 'Adicionar', isPrimary: true, onPressed: _adicionarAoCabaz),
                                  _CabazButton(text: 'Limpar', isPrimary: false, onPressed: _limparCabaz),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _guardarCabaz,
                                icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
                                label: const Text('Guardar Cabaz', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF004D40), // A darker shade of green
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 2, color: Color(0xFF2E7D5A)),
              const SizedBox(height: 16),
              _buildCabazesGuardadosSection(),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/images/doubt_icon.png', height: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Alguma Dúvida?',
                      style: GoogleFonts.lilitaOne(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Entre em contacto conosco!',
                        style: GoogleFonts.lilitaOne(
                          color: const Color(0xFF2E7D5A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_meusProdutos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Nenhum produto criado ainda.\nClique em "Criar Novo Produto" para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemCount: _meusProdutos.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final produto = _meusProdutos[index];
        return _ProductPresetCard(
          image: produto['imagem'],
          name: produto['nome'] ?? 'Sem nome',
          onEdit: () {
            _navigateToCreateEditPage(produto: produto);
          },
          onDelete: () => _apagarProduto(produto['id']),
        );
      },
    );
  }

  Widget _buildCabazesGuardadosSection() {
    return Column(
      children: [
        Text(
          'Meus Cabazes',
          style: GoogleFonts.lilitaOne(
            fontSize: 22,
            color: const Color(0xFF2E7D5A),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingCabazes)
          const Center(child: CircularProgressIndicator())
        else if (_meusCabazes.isEmpty)
          const Text('Nenhum cabaz guardado ainda.', style: TextStyle(color: Colors.grey))
        else
          ExpansionPanelList(
            elevation: 2,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _openCabazPanelIndex = isExpanded ? -1 : index;
              });
            },
            children: _meusCabazes.asMap().map((index, cabaz) {
              final isExpanded = _openCabazPanelIndex == index;
              final produtos = (cabaz['produtosDetalhados'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              
              return MapEntry(
                index,
                ExpansionPanel(
                  isExpanded: isExpanded,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text(cabaz['nome'] ?? 'Cabaz sem nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${produtos.length} produtos'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _apagarCabaz(cabaz['id']),
                      ),
                    );
                  },
                  body: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: produtos.map((produto) => _MiniProductChip(
                        image: produto['imagem'],
                        name: produto['nome'],
                      )).toList(),
                    ),
                  ),
                ),
              );
            }).values.toList(),
          ),
      ],
    );
  }
}

class _ProductPresetCard extends StatelessWidget {
  final String? image;
  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductPresetCard({
    this.image,
    required this.name,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (image != null && image!.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(image!);
        imageWidget = Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } catch (e) {
        print("Erro ao decodificar imagem Base64: $e");
        imageWidget = const Tooltip(
          message: 'Erro no formato da imagem',
          child: Icon(Icons.broken_image, size: 40, color: Colors.red),
        );
      }
    } else {
      imageWidget = const Tooltip(
        message: 'Produto sem imagem',
        child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey),
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E7D5A), width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: SizedBox.expand(child: imageWidget),
                  ),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 12,
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.lilitaOne(fontSize: 14, color: Colors.black87),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D5A),
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 28),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: onEdit,
          child: const Text('Editar', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

class _BasketProductChip extends StatelessWidget {
  final String? image;
  final String name;
  const _BasketProductChip({this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (image != null && image!.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(image!);
        imageWidget = Image.memory(decodedBytes, fit: BoxFit.cover, gaplessPlayback: true);
      } catch (e) {
        imageWidget = const Icon(Icons.broken_image, size: 24, color: Colors.white);
      }
    } else {
      imageWidget = const Icon(Icons.inventory_2_outlined, size: 24, color: Colors.white);
    }

    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageWidget,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: GoogleFonts.lilitaOne(fontSize: 11, color: Colors.white),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _CabazButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _CabazButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.transparent,
        foregroundColor: isPrimary ? const Color(0xFF2E7D5A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.white, width: 1.5),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        textStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class _MiniProductChip extends StatelessWidget {
  final String? image;
  final String? name;

  const _MiniProductChip({this.image, this.name});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (image != null && image!.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(image!);
        imageWidget = Image.memory(decodedBytes, fit: BoxFit.cover);
      } catch (e) {
        imageWidget = const Icon(Icons.broken_image, size: 20, color: Colors.grey);
      }
    } else {
      imageWidget = const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey);
    }

    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.white,
        child: ClipOval(child: imageWidget),
      ),
      label: Text(name ?? 'Sem nome'),
      backgroundColor: Colors.green[50],
    );
  }
}
