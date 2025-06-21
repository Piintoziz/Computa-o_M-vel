import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

class ProductsPageCriarEditar extends StatefulWidget {
  final Map<String, dynamic>? produtoParaEditar;

  const ProductsPageCriarEditar({Key? key, this.produtoParaEditar}) : super(key: key);

  @override
  _ProductsPageCriarEditarState createState() => _ProductsPageCriarEditarState();
}

class _ProductsPageCriarEditarState extends State<ProductsPageCriarEditar> {
  int _selectedEntrega = 1;
  final _descricaoController = TextEditingController();
  
  String? _medidaAtual;
  String? _medidaNova;
  final _precoNovoController = TextEditingController();
  final _quantidadeNovaController = TextEditingController();
  final _nomeController = TextEditingController();

  // Campos adicionados para espelhar a página de anúncio
  String? _categoriaSelecionada;
  final _localizacaoController = TextEditingController();
  final _campoAdicionalController = TextEditingController();
  final _nomeContactoController = TextEditingController();
  final _telefoneContactoController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _imagem;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.produtoParaEditar != null) {
      _preencherCampos();
    }
  }

  void _preencherCampos() {
    final produto = widget.produtoParaEditar!;
    _nomeController.text = produto['nome'] ?? '';
    _medidaNova = produto['medida'];
    _precoNovoController.text = produto['preco']?.toString() ?? '0.0';
    _quantidadeNovaController.text = produto['quantidade']?.toString() ?? '0';
    _descricaoController.text = produto['descricao'] ?? '';
    _selectedEntrega = produto['opcaoEntrega'] ?? 1;

    // Preencher novos campos
    _categoriaSelecionada = produto['categoria'];
    _localizacaoController.text = produto['localizacao'] ?? '';
    _campoAdicionalController.text = produto['campoAdicional'] ?? '';
    _nomeContactoController.text = produto['nomeContacto'] ?? '';
    _telefoneContactoController.text = produto['telefoneContacto'] ?? '';
    // Nota: A imagem não é carregada para edição aqui, o utilizador terá de selecionar uma nova se quiser alterar.
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _precoNovoController.dispose();
    _quantidadeNovaController.dispose();
    _nomeController.dispose();
    
    // Dispose dos novos controllers
    _localizacaoController.dispose();
    _campoAdicionalController.dispose();
    _nomeContactoController.dispose();
    _telefoneContactoController.dispose();

    super.dispose();
  }

  Future<void> _saveProduct() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty || _imagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, adicione um nome e uma imagem ao produto.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utilizador não autenticado.')));
      setState(() => _isSaving = false);
      return;
    }

    try {
      final imageBytes = await _imagem!.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      final productData = {
        'uid': user.uid,
        'nome': nome,
        'imagem': imageBase64,
        'medida': _medidaNova,
        'preco': double.tryParse(_precoNovoController.text.trim().replaceAll(',', '.')) ?? 0.0,
        'quantidade': int.tryParse(_quantidadeNovaController.text.trim()) ?? 0,
        'descricao': _descricaoController.text.trim(),
        'opcaoEntrega': _selectedEntrega,
        // Novos campos
        'categoria': _categoriaSelecionada,
        'localizacao': _localizacaoController.text.trim(),
        'campoAdicional': _campoAdicionalController.text.trim(),
        'nomeContacto': _nomeContactoController.text.trim(),
        'telefoneContacto': _telefoneContactoController.text.trim(),
      };
      
      if (widget.produtoParaEditar != null) {
        final produtoId = widget.produtoParaEditar!['id'];
        await FirebaseDatabase.instance.ref('produtos/$produtoId').update(productData);
      } else {
        await FirebaseDatabase.instance.ref('produtos').push().set(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.produtoParaEditar != null ? 'Produto atualizado com sucesso!' : 'Produto guardado com sucesso!'),
            backgroundColor: const Color(0xFF2E7D5A)
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao guardar produto: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80, maxHeight: 1024, maxWidth: 1024);
      if (pickedFile != null) {
        setState(() {
          _imagem = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  void _showImageSourceActionSheet() {
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
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmara'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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
            Text('Gestão', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Tudo num só lugar!', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Criação / Edição de Produto',
                style: GoogleFonts.lilitaOne(fontSize: 22, color: const Color(0xFF2E7D5A)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(),
                const SizedBox(width: 12),
                Expanded(child: _buildWarningBox()),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Informações de Venda'),
            _buildSalesFields(),
            const SizedBox(height: 20),
            
            _buildSectionTitle('Detalhes Padrão para Anúncios'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 12),
            _buildLocationTextField(),
            const SizedBox(height: 12),
            _buildDescriptionTextField(),
            const SizedBox(height: 12),
            _buildAdditionalFieldTextField(),
            const SizedBox(height: 20),

            _buildSectionTitle('Contacto Padrão para Anúncios'),
            const SizedBox(height: 8),
            _buildContactFields(),
            const SizedBox(height: 20),

            _buildSectionTitle('Selecione a opção de entrega desejada'),
            _buildDeliveryOptions(),
            const SizedBox(height: 24),

            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceActionSheet,
          child: Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E7D5A), width: 3),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: _imagem != null
                  ? Image.file(File(_imagem!.path), fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
                        const SizedBox(height: 4),
                        Text('Adicionar\nFoto',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 110,
          child: TextField(
            controller: _nomeController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Nome do Produto',
              isDense: true,
              border: InputBorder.none,
              hintStyle: GoogleFonts.lilitaOne(fontSize: 16, color: Colors.grey),
            ),
            style: GoogleFonts.lilitaOne(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D5A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                children: const [
                  TextSpan(text: 'Todas as alterações feitas ao produto serão aplicadas a todos os '),
                  TextSpan(text: 'anúncios', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                  TextSpan(text: ' que contenham este mesmo produto.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesFields() {
    return Column(
      children: [
        Row(
          children: [
            _buildFormColumn('Preço', _buildTextField(_precoNovoController, 'Preço', suffix: '€')),
            const SizedBox(width: 12),
            _buildFormColumn('Medida', _buildDropdown(['Kg', 'Unidade', 'Litro', 'Outro'], _medidaNova, 'Medida', (v) => setState(() => _medidaNova = v))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFormColumn('Quantidade', _buildTextField(_quantidadeNovaController, 'Quantidade')),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()), // Espaço para alinhar
          ],
        ),
      ],
    );
  }
  
  Widget _buildFormColumn(String title, Widget field) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          field,
        ],
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? value, String hint, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(TextEditingController? controller, String hint, {bool enabled = true, String? suffix, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: !enabled,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Column(
      children: [
        _buildRadioTile('Entrega domicílio (Produtor)', 0),
        _buildRadioTile('Consumidor recolhe num local à sua escolha', 1),
        _buildRadioTile('Entrega realizada por transportadora', 2),
      ],
    );
  }

  RadioListTile<int> _buildRadioTile(String title, int value) {
    return RadioListTile<int>(
      title: Text(title, style: TextStyle(color: _selectedEntrega == value ? Colors.black : Colors.grey[600])),
      value: value,
      groupValue: _selectedEntrega,
      onChanged: (v) => setState(() => _selectedEntrega = v!),
      activeColor: const Color(0xFF2E7D5A),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D5A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(widget.produtoParaEditar != null ? 'Guardar Alterações' : 'Confirmar', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildDropdown(['Frutas', 'Legumes', 'Laticínios', 'Outros'], _categoriaSelecionada, 'Categoria', (v) => setState(() => _categoriaSelecionada = v));
  }

  Widget _buildLocationTextField() {
    return _buildTextField(_localizacaoController, 'Localização');
  }

  Widget _buildDescriptionTextField() {
    return _buildTextField(_descricaoController, '*Descrição do produto aqui*', maxLines: 4);
  }

  Widget _buildAdditionalFieldTextField() {
    return _buildTextField(_campoAdicionalController, 'Campo Adicional (Ex: Cor, Tamanho)');
  }

  Widget _buildContactFields() {
    return Row(
      children: [
        _buildFormColumn('Nome', _buildTextField(_nomeContactoController, 'Nome para contacto')),
        const SizedBox(width: 12),
        _buildFormColumn('Telefone', _buildTextField(_telefoneContactoController, 'Nº Telefone', keyboardType: TextInputType.phone)),
      ],
    );
  }
}
