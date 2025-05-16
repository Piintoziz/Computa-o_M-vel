import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'pages/detalhes_encomenda_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D5A)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.getRoutes(),
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.detalhesEncomenda) {
          final encomenda = settings.arguments as dynamic;
          return MaterialPageRoute(
            builder: (context) => DetalhesEncomendaPage(
              cliente: encomenda.cliente,
              id: encomenda.id,
              estado: encomenda.estadoAtual,
              dataPedido: encomenda.data,
              itens: encomenda.itens,
              metodoPagamento: encomenda.metodoPagamento,
              enderecoEntrega: encomenda.enderecoEntrega,
            ),
          );
        }
        return null;
      },
    );
  }
}
