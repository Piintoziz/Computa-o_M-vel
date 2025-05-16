import 'item_encomenda.dart';

class Encomenda {
  final String id;
  final String cliente;
  final String estadoAtual;
  final DateTime data;
  final List<ItemEncomenda> itens;
  final String metodoPagamento;
  final String enderecoEntrega;

  Encomenda({
    required this.id,
    required this.cliente,
    required this.estadoAtual,
    required this.data,
    required this.itens,
    required this.metodoPagamento,
    required this.enderecoEntrega,
  });

  // Método para converter de JSON
  factory Encomenda.fromJson(Map<String, dynamic> json) {
    return Encomenda(
      id: json['id'] as String,
      cliente: json['cliente'] as String,
      estadoAtual: json['estadoAtual'] as String,
      data: DateTime.parse(json['data'] as String),
      itens: (json['itens'] as List)
          .map((item) => ItemEncomenda.fromJson(item as Map<String, dynamic>))
          .toList(),
      metodoPagamento: json['metodoPagamento'] as String,
      enderecoEntrega: json['enderecoEntrega'] as String,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'estadoAtual': estadoAtual,
      'data': data.toIso8601String(),
      'itens': itens.map((item) => item.toJson()).toList(),
      'metodoPagamento': metodoPagamento,
      'enderecoEntrega': enderecoEntrega,
    };
  }
} 