class ItemEncomenda {
  final String nome;
  final String quantidade;
  final double preco;
  final String imagemUrl;

  ItemEncomenda({
    required this.nome,
    required this.quantidade,
    required this.preco,
    required this.imagemUrl,
  });

  // Método para converter de JSON
  factory ItemEncomenda.fromJson(Map<String, dynamic> json) {
    return ItemEncomenda(
      nome: json['nome'] as String,
      quantidade: json['quantidade'] as String,
      preco: (json['preco'] as num).toDouble(),
      imagemUrl: json['imagemUrl'] as String,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'preco': preco,
      'imagemUrl': imagemUrl,
    };
  }
} 