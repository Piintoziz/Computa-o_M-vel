import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


class PublicarAnuncioPage extends StatefulWidget {
  final VoidCallback? onPublishSuccess;
  final VoidCallback? onBackToIndex;
  final Map<String, dynamic>? anuncioParaEditar;

  const PublicarAnuncioPage({
    Key? key,
    this.onPublishSuccess,
    this.onBackToIndex,
    this.anuncioParaEditar,
  }) : super(key: key);

  @override
  State<PublicarAnuncioPage> createState() => _PublicarAnuncioPageState();
}

class _PublicarAnuncioPageState extends State<PublicarAnuncioPage> {
  int _selectedEntrega = 0;
  final List<String> _entregaOptions = [
    'Entrega domicílio (Produtor)',
    'Consumidor recolhe num local à sua escolha',
    'Entrega realizada por transportadora',
  ];

  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _imagens = [null, null, null];

  final _tituloController = TextEditingController();
  String? _categoriaSelecionada;
  final _descricaoController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();
  String? _medidaSelecionada;
  final _campoAdicionalController = TextEditingController();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  bool _isPickingImage = false;
  
  List<Map<String, dynamic>> _meusProdutos = [];
  List<Map<String, dynamic>> _meusCabazes = [];
  bool _isLoadingPresets = true;

  @override
  void initState() {
    super.initState();
    if (widget.anuncioParaEditar != null) {
      _preencherCamposParaEdicao();
    }
    _carregarDadosPresets();
  }

  Future<void> _carregarDadosPresets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingPresets = false);
      return;
    }

    // Carregar Produtos
    final produtosRef = FirebaseDatabase.instance.ref('produtos').orderByChild('uid').equalTo(user.uid);
    final produtosSnapshot = await produtosRef.get();
    final List<Map<String, dynamic>> produtosTemp = [];
    if (produtosSnapshot.exists && produtosSnapshot.value != null) {
      final data = produtosSnapshot.value as Map;
      data.forEach((key, value) {
        final produtoData = Map<String, dynamic>.from(value as Map);
        produtoData['id'] = key;
        produtosTemp.add(produtoData);
      });
    }

    // Carregar Cabazes
    final cabazesRef = FirebaseDatabase.instance.ref('cabazes').orderByChild('uid').equalTo(user.uid);
    final cabazesSnapshot = await cabazesRef.get();
    final List<Map<String, dynamic>> cabazesTemp = [];
    if (cabazesSnapshot.exists && cabazesSnapshot.value != null) {
        final data = cabazesSnapshot.value as Map;
        data.forEach((key, value) {
            if (value is Map) {
                final cabazData = Map<String, dynamic>.from(value);
                cabazData['id'] = key;
                
                if (cabazData['produtos'] is List) {
                    List<Map<String, dynamic>> produtosDetalhados = [];
                    for (var produtoId in cabazData['produtos']) {
                        final produto = produtosTemp.firstWhere(
                            (p) => p['id'] == produtoId,
                            orElse: () => {},
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

    if (mounted) {
      setState(() {
        _meusProdutos = produtosTemp;
        _meusCabazes = cabazesTemp;
        _isLoadingPresets = false;
      });
    }
  }

  void _aplicarPresetProduto(Map<String, dynamic> produto) async {
    if (!mounted) return;

    XFile? imagemPreset;
    if (produto['imagem'] != null && (produto['imagem'] as String).isNotEmpty) {
      try {
        final decodedBytes = base64Decode(produto['imagem']);
        final tempDir = await Directory.systemTemp.createTemp();
        final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(decodedBytes);
        imagemPreset = XFile(file.path);
      } catch (e) {
        print("Erro ao converter imagem do preset: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao carregar a imagem do produto.'))
          );
        }
      }
    }

    setState(() {
      _tituloController.text = produto['nome'] ?? '';
      _categoriaSelecionada = produto['categoria'];
      _descricaoController.text = produto['descricao'] ?? '';
      _precoController.text = produto['preco']?.toString() ?? '';
      _medidaSelecionada = produto['medida'];
      _quantidadeController.text = produto['quantidade']?.toString() ?? '1';

      // Preencher campos adicionais
      _localizacaoController.text = produto['localizacao'] ?? '';
      _campoAdicionalController.text = produto['campoAdicional'] ?? '';
      _nomeController.text = produto['nomeContacto'] ?? '';
      _telefoneController.text = produto['telefoneContacto'] ?? '';
      _selectedEntrega = produto['opcaoEntrega'] ?? 0;

      _imagens.fillRange(0, _imagens.length, null);
      if (imagemPreset != null) {
        _imagens[0] = imagemPreset;
      }
    });
  }

  void _aplicarPresetCabaz(Map<String, dynamic> cabaz) async {
    if (!mounted) return;

    final produtosDetalhados = (cabaz['produtosDetalhados'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    List<XFile?> novasImagens = [null, null, null];
    int imageIndex = 0;

    for (var produto in produtosDetalhados) {
        if (imageIndex >= 3) break;
        if (produto['imagem'] != null && (produto['imagem'] as String).isNotEmpty) {
            try {
                final decodedBytes = base64Decode(produto['imagem']);
                final tempDir = await Directory.systemTemp.createTemp();
                final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
                await file.writeAsBytes(decodedBytes);
                novasImagens[imageIndex] = XFile(file.path);
                imageIndex++;
            } catch (e) {
                print("Erro ao converter imagem do preset de cabaz: $e");
            }
        }
    }

    if (!mounted) return;

    setState(() {
      _tituloController.text = cabaz['nome'] ?? 'Cabaz';
      final nomesProdutos = produtosDetalhados.map((p) => p['nome'] as String? ?? 'Sem nome').toList();
      _descricaoController.text = 'Este cabaz contém: ${nomesProdutos.join(', ')}.';
      _precoController.clear();
      _medidaSelecionada = 'Unidade';
      _quantidadeController.text = '1';
      
      for(int i=0; i < _imagens.length; i++) {
        _imagens[i] = novasImagens[i];
      }
    });
  }

  void _mostrarDialogoPresets() async {
    final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Carregar Preset'),
            content: DefaultTabController(
              length: 2,
              child: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Produtos'),
                        Tab(text: 'Cabazes'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _isLoadingPresets
                            ? const Center(child: CircularProgressIndicator())
                            : _meusProdutos.isEmpty
                                ? const Center(child: Text("Nenhum produto criado."))
                                : ListView.builder(
                                    itemCount: _meusProdutos.length,
                                    itemBuilder: (context, index) {
                                      final produto = _meusProdutos[index];
                                      return ListTile(
                                        title: Text(produto['nome'] ?? 'Sem nome'),
                                        onTap: () => Navigator.of(dialogContext).pop({'type': 'produto', 'data': produto}),
                                      );
                                    },
                                  ),
                          _isLoadingPresets
                            ? const Center(child: CircularProgressIndicator())
                            : _meusCabazes.isEmpty
                                ? const Center(child: Text("Nenhum cabaz criado."))
                                : ListView.builder(
                                    itemCount: _meusCabazes.length,
                                    itemBuilder: (context, index) {
                                      final cabaz = _meusCabazes[index];
                                      return ListTile(
                                        title: Text(cabaz['nome'] ?? 'Sem nome'),
                                        subtitle: Text('${(cabaz['produtos'] as List?)?.length ?? 0} produtos'),
                                        onTap: () => Navigator.of(dialogContext).pop({'type': 'cabaz', 'data': cabaz}),
                                      );
                                    },
                                  ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          );
        });

    if (result == null || !mounted) return;

    final type = result['type'];
    final data = result['data'];

    if (type == 'produto') {
      _aplicarPresetProduto(data);
    } else if (type == 'cabaz') {
      _aplicarPresetCabaz(data);
    }
  }

  void _preencherCamposParaEdicao() {
    final data = widget.anuncioParaEditar!;
    _tituloController.text = data['titulo'] ?? '';
    _categoriaSelecionada = (data['categoria'] as String?)?.trim();
    _descricaoController.text = data['descricao'] ?? '';
    _localizacaoController.text = data['localizacao'] ?? '';
    _quantidadeController.text = data['quantidadeMinima']?.toString() ?? '';
    _precoController.text = data['preco']?.toString() ?? '';
    _medidaSelecionada = data['medida'];
    _campoAdicionalController.text = data['campoAdicional'] ?? '';
    _nomeController.text = data['nome'] ?? '';
    _telefoneController.text = data['telefone'] ?? '';

    final entrega = data['opcaoEntrega'];
    if (entrega != null) {
      final index = _entregaOptions.indexOf(entrega);
      if (index != -1) {
        _selectedEntrega = index;
      }
    }
  }

  Future<void> _pickImage(int index, ImageSource source) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imagens[index] = pickedFile;
        });
      }
    } finally {
      _isPickingImage = false;
    }
  }

  void _showImageSourceActionSheet(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  _pickImage(index, ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmara'),
                onTap: () {
                  _pickImage(index, ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imagens[index] = null;
    });
  }

  Future<void> publicarAnuncio() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É necessário estar autenticado para publicar um anúncio.')),
      );
      return;
    }

    List<String> imageBase64List = [];
    bool newImagesSelected = _imagens.any((img) => img != null);
    if (newImagesSelected) {
      for (int i = 0; i < _imagens.length; i++) {
        if (_imagens[i] != null) {
          File imageFile = File(_imagens[i]!.path);
          final bytes = await imageFile.readAsBytes();
          imageBase64List.add(base64Encode(bytes));
        }
      }
    } else if (widget.anuncioParaEditar != null) {
      imageBase64List = List<String>.from(widget.anuncioParaEditar!['fotos'] ?? []);
    }
    
    final dataToSave = {
      'uid': user.uid,
      'titulo': _tituloController.text.trim(),
      'categoria': _categoriaSelecionada,
      'descricao': _descricaoController.text.trim(),
      'localizacao': _localizacaoController.text.trim(),
      'opcaoEntrega': _entregaOptions[_selectedEntrega],
      'quantidadeMinima': int.tryParse(_quantidadeController.text.trim()) ?? 0,
      'preco': double.tryParse(_precoController.text.trim().replaceAll(',', '.')) ?? 0.0,
      'medida': _medidaSelecionada,
      'campoAdicional': _campoAdicionalController.text.trim(),
      'nome': _nomeController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'dataPublicacao': widget.anuncioParaEditar != null
          ? widget.anuncioParaEditar!['dataPublicacao']
          : dataFormatada,
      'fotos': imageBase64List,
    };

    try {
      if (widget.anuncioParaEditar != null) {
        final anuncioId = widget.anuncioParaEditar!['id'];
        await FirebaseDatabase.instance.ref('anuncios/$anuncioId').update(dataToSave);
      } else {
        await FirebaseDatabase.instance.ref('anuncios').push().set(dataToSave);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.anuncioParaEditar != null ? 'Anúncio atualizado!' : 'Anúncio publicado!'),
            backgroundColor: const Color(0xFF2E7D5A),
          ),
        );
        widget.onPublishSuccess?.call();
      }
    } catch (e) {
      print("Erro ao guardar anúncio na Realtime Database: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao guardar anúncio: ${e.toString()}')),
      );
    }
  }

  void _mostrarPreVisualizacao() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Pré-visualização do Anúncio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF2E7D5A))),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _imagens.where((img) => img != null).isNotEmpty
                    ? _imagens.where((img) => img != null).map((img) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(img!.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )).toList()
                    : [const Icon(Icons.image, size: 60, color: Colors.grey)],
                ),
                const SizedBox(height: 16),
                _linhaPreview('Título:', _tituloController.text),
                _linhaPreview('Categoria:', _categoriaSelecionada ?? ''),
                _linhaPreview('Descrição:', _descricaoController.text),
                _linhaPreview('Localização:', _localizacaoController.text),
                _linhaPreview('Opção de Entrega:', _entregaOptions[_selectedEntrega]),
                _linhaPreview('Quantidade mínima:', _quantidadeController.text),
                _linhaPreview('Preço:', _precoController.text + ' €'),
                _linhaPreview('Medida:', _medidaSelecionada ?? ''),
                if (_campoAdicionalController.text.isNotEmpty)
                  _linhaPreview('Campo Adicional:', _campoAdicionalController.text),
                const Divider(),
                const Text('Dados de Contacto', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D5A))),
                _linhaPreview('Nome:', _nomeController.text),
                _linhaPreview('Telefone:', _telefoneController.text),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _linhaPreview(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onBackToIndex != null) {
              widget.onBackToIndex!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          widget.anuncioParaEditar != null ? 'Editar Anúncio' : 'Publicar anúncio',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _mostrarDialogoPresets,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Carregar Preset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fotos do seu produto',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) => Expanded(
                child: GestureDetector(
                  onTap: () => _showImageSourceActionSheet(index),
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _imagens[index] == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 36, color: Colors.grey),
                              SizedBox(height: 4),
                              Text('Adicionar fotos', style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imagens[index]!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 20),
            
            TextField(
             controller: _tituloController,
             textAlign: TextAlign.center,
             decoration: InputDecoration(
               hintText: 'Título Apelativo',
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
               focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
               filled: true,
               fillColor: Colors.white,
             ),
            ),

            const SizedBox(height: 12),

            // CAMPOS REORDENADOS PARA FICAR IGUAL À IMAGEM
            
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _categoriaSelecionada,
              onChanged: (v) => setState(() => _categoriaSelecionada = v),
              decoration: InputDecoration(
                hintText: 'Categoria',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
              alignment: Alignment.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
                height: 1.2,
              ),
              items: [
                'Frutas', 'Legumes', 'Laticínios', 'Outros'
              ].map((cat) => DropdownMenuItem(value: cat, child: Center(child: Text(cat)))).toList(),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _descricaoController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Descrição',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),

            TextField(
              controller: _localizacaoController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Localização',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 18),
            
            const Text(
              'Selecione as suas opções de entrega',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(_entregaOptions.length, (i) => RadioListTile<int>(
                value: i,
                groupValue: _selectedEntrega,
                onChanged: (v) => setState(() => _selectedEntrega = v!),
                activeColor: const Color(0xFF2E7D5A),
                title: Text(
                  _entregaOptions[i],
                  style: TextStyle(
                    color: _selectedEntrega == i ? const Color(0xFF2E7D5A) : Colors.grey,
                    fontWeight: _selectedEntrega == i ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              )),
            ),
            
            const SizedBox(height: 18),
            
            const Text('Detalhes da venda', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantidadeController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Quantidade mínima',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _precoController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]{0,2}')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Preço',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            filled: true,
                            fillColor: Colors.white,
                            suffixText: '€',
                            suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _medidaSelecionada,
                    onChanged: (v) => setState(() => _medidaSelecionada = v),
                    decoration: InputDecoration(
                      hintText: 'Medida',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    alignment: Alignment.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      height: 1.2,
                    ),
                    items: [
                      'Kg', 'Unidade', 'Litro', 'Outro'
                    ].map((med) => DropdownMenuItem(value: med, child: Center(child: Text(med)))).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _campoAdicionalController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Campo Adicional',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text('Dados de Contacto', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomeController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Nome',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _telefoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'NºTelefone',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D5A))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cancelar anúncio'),
                          content: const Text('Tem a certeza que quer cancelar?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Não'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Sim'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        if (widget.onBackToIndex != null) {
                          widget.onBackToIndex!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _mostrarPreVisualizacao();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D5A),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Pré-visualizar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validação dos campos obrigatórios
                      bool camposValidos =
                        _tituloController.text.trim().isNotEmpty &&
                        _categoriaSelecionada != null &&
                        _descricaoController.text.trim().isNotEmpty &&
                        _quantidadeController.text.trim().isNotEmpty &&
                        _precoController.text.trim().isNotEmpty &&
                        _medidaSelecionada != null &&
                        _nomeController.text.trim().isNotEmpty &&
                        _telefoneController.text.trim().isNotEmpty;
                      if (camposValidos) {
                        await publicarAnuncio();
                        await Future.delayed(const Duration(milliseconds: 1500));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, preencha todos os campos obrigatórios.'),
                            backgroundColor: Color.fromARGB(255, 161, 47, 39),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(widget.anuncioParaEditar != null ? 'Guardar' : 'Publicar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
