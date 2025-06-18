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
  const PublicarAnuncioPage({Key? key, this.onPublishSuccess, this.onBackToIndex}) : super(key: key);

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

  Future<void> _pickImage(int index) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imagens[index] = pickedFile;
        });
      }
    } finally {
      _isPickingImage = false;
    }
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

    final anuncioRef = FirebaseDatabase.instance.ref('anuncios').push();

    // Guardar imagens como Base64
    List<String> imageBase64List = [];
    for (int i = 0; i < _imagens.length; i++) {
      if (_imagens[i] != null) {
        File imageFile = File(_imagens[i]!.path);
        final bytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(bytes);
        imageBase64List.add(base64Image);
      }
    }

    try {
      await anuncioRef.set({
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
        'dataPublicacao': dataFormatada,
        'fotos': imageBase64List,
      });
    } catch (e) {
      print("Erro ao guardar anúncio na Realtime Database: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao guardar anúncio: ${e.toString()}')),
      );
      return;
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
        title: const Text(
          'Publicar anúncio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) => Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(index),
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
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _categoriaSelecionada,
                onChanged: (v) => setState(() => _categoriaSelecionada = v),
                decoration: InputDecoration(
                  hintText: '      Categoria',
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
                  '      Frutas', '      Legumes', '      Laticínios', '      Outros'
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Anúncio publicado com sucesso!'),
                              backgroundColor: Color(0xFF2E7D5A),
                              duration: Duration(milliseconds: 1500),
                            ),
                          );
                          await Future.delayed(const Duration(milliseconds: 1500));
                          if (widget.onPublishSuccess != null) {
                            widget.onPublishSuccess!();
                          }
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
                      child: const Text('Publicar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
