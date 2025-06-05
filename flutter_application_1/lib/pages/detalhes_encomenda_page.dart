import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item_encomenda.dart';

class DetalhesEncomendaPage extends StatelessWidget {
  final String cliente;
  final String id;
  final String estado;
  final DateTime dataPedido;
  final List<ItemEncomenda> itens;
  final String metodoPagamento;
  final String enderecoEntrega;

  const DetalhesEncomendaPage({
    Key? key,
    required this.cliente,
    required this.id,
    required this.estado,
    required this.dataPedido,
    required this.itens,
    required this.metodoPagamento,
    required this.enderecoEntrega,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = itens.fold<double>(0, (sum, item) => sum + item.preco);
    return Scaffold(
      backgroundColor: Colors.white,
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
            Text('Detalhes - Encomendas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
            SizedBox(height: 2),
            Text('Tudo num só lugar!', style: TextStyle(fontSize: 13, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 24),
                  const SizedBox(width: 8),
                  Text(cliente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ID', style: TextStyle(color: Colors.black54)),
                  Text('#$id', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estado', style: TextStyle(color: Colors.black54)),
                  Text(estado, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Data do pedido', style: TextStyle(color: Colors.black54)),
                  Text(DateFormat('d MMM yyyy, HH:mm').format(dataPedido), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              ...itens.map((item) => Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imagemUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D5A)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(item.quantidade, style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                      Text('€ ${item.preco.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                  const Divider(),
                ],
              )),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Método de pagamento', style: TextStyle(color: Colors.black54)),
                  const Spacer(),
                  Text(metodoPagamento, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Endereço de Entrega', style: TextStyle(color: Colors.black54)),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: Text(enderecoEntrega, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D5A),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Total: ${total.toStringAsFixed(2)}€',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
} 