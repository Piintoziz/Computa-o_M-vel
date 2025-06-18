import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/encomenda.dart';


class OrdersPage extends StatelessWidget {
  final String customerUid;
  OrdersPage({super.key, required this.customerUid});

  // Static orders data (simulate a database)
  final List<Encomenda> allOrders = [
    Encomenda(
      id: '1074',
      cliente: 'uid1',
      estadoAtual: 'Pendente',
      data: DateTime(2025, 4, 12, 14, 1),
      itens: [],
      metodoPagamento: 'Cartão',
      enderecoEntrega: '',
    ),
    Encomenda(
      id: '1073',
      cliente: 'uid1',
      estadoAtual: 'Cancelado',
      data: DateTime(2025, 4, 12, 13, 37),
      itens: [],
      metodoPagamento: 'Cartão',
      enderecoEntrega: '',
    ),
    Encomenda(
      id: '1035',
      cliente: 'uid1',
      estadoAtual: 'Em processamento',
      data: DateTime(2025, 4, 2, 17, 35),
      itens: [],
      metodoPagamento: 'Cartão',
      enderecoEntrega: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseDatabase.instance.ref('userdata/$customerUid').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data?.value == null) {
          return const Center(child: Text('Cliente não encontrado'));
        }
        final data = Map<String, dynamic>.from(snapshot.data!.value as Map);
        final orders = allOrders;//.where((o) => o.cliente == customerUid).toList();

        return Scaffold(
          appBar: AppBar(
          title: const Text('Clientes', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
          backgroundColor: const Color(0xFFF5F5F5),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(data['phone'] ?? '', style: const TextStyle(fontSize: 16)),
                  Text(data['email'] ?? '', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ...orders.map((order) => _OrderCard(order: order)).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Encomenda order;
  const _OrderCard({required this.order});

  Color get statusColor {
    switch (order.estadoAtual) {
      case 'Pendente':
        return const Color(0xFF21805C);
      case 'Cancelado':
        return const Color(0xFFC62828);
      case 'Em processamento':
        return const Color(0xFF21805C);
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (order.estadoAtual) {
      case 'Pendente':
        return 'Pendente';
      case 'Cancelado':
        return 'Cancelado';
      case 'Em processamento':
        return 'Em processamento';
      default:
        return order.estadoAtual;
    }
  }

  // Simulate order value for demo
  String get orderValue {
    if (order.id == '1074') return '23,45€';
    if (order.id == '1073') return '21,37€';
    if (order.id == '1035') return '21,37€';
    return '0,00€';
  }

  // Simulate progress for demo
  List<_OrderStep> get steps {
    if (order.id == '1074') {
      return [
        const _OrderStep(icon: Icons.inventory_2, label: 'Packing', done: true),
        const _OrderStep(icon: Icons.inbox, label: 'Recolha', done: false),
        const _OrderStep(icon: Icons.local_shipping, label: 'Transporte', done: false),
        const _OrderStep(icon: Icons.home, label: 'Entrega', done: false),
      ];
    } else if (order.id == '1073') {
      return [
        const _OrderStep(icon: Icons.inventory_2, label: 'Packing', done: true),
        const _OrderStep(icon: Icons.inbox, label: 'Recolha', done: true),
        const _OrderStep(icon: Icons.local_shipping, label: 'Transporte', done: true),
        const _OrderStep(icon: Icons.cancel, label: 'Entrega', done: false, canceled: true),
      ];
    } else if (order.id == '1035') {
      return [
        const _OrderStep(icon: Icons.inventory_2, label: 'Packing', done: true),
        const _OrderStep(icon: Icons.inbox, label: 'Recolha', done: true),
        const _OrderStep(icon: Icons.local_shipping, label: 'Transporte', done: false),
        const _OrderStep(icon: Icons.home, label: 'Entrega', done: false),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              Text(orderValue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${order.data.day.toString().padLeft(2, '0')} Apr ${order.data.year}, ${order.data.hour.toString().padLeft(2, '0')}:${order.data.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: steps.map((step) {
              final isLast = step == steps[steps.length - 2];
              return Row(
                children: [
                  Column(
                    children: [
                      Icon(step.icon, size: 24, color: step.canceled ? Colors.red : (step.done ? const Color(0xFF21805C) : Colors.black45)),
                      const SizedBox(width: 2),
                      Text(step.label, style: TextStyle(fontSize: 12, color: step.canceled ? Colors.red : (step.done ? const Color(0xFF21805C) : Colors.black45))),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
                    const SizedBox(width: 4),
                  ],
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                statusText,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStep {
  final IconData icon;
  final String label;
  final bool done;
  final bool canceled;
  const _OrderStep({required this.icon, required this.label, this.done = false, this.canceled = false});
}