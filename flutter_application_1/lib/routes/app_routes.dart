import 'package:flutter/material.dart';
import '../pages/home_navigation.dart';
import '../pages/proximas_entregas_page.dart';
import '../pages/publicar_anuncio_page.dart';
import '../pages/gestão_Encomendas.dart';
import '../pages/detalhes_encomenda_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String proximasEntregas = '/proximas-entregas';
  static const String publicarAnuncio = '/publicar-anuncio';
  static const String gestaoEncomendas = '/gestao-encomendas';
  static const String detalhesEncomenda = '/detalhes-encomenda';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeNavigation(),
      proximasEntregas: (context) => ProximasEntregasPage(),
      publicarAnuncio: (context) => PublicarAnuncioPage(
        onPublishSuccess: () => Navigator.pop(context),
        onBackToIndex: () => Navigator.pop(context),
      ),
      gestaoEncomendas: (context) => GestaoEncomendasPage(
        onBack: () => Navigator.pop(context),
      ),
    };
  }

  // Função para navegar para detalhes da encomenda com parâmetros
  static void navigateToDetalhesEncomenda(BuildContext context, dynamic encomenda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesEncomendaPage(
          cliente: encomenda.cliente,
          id: encomenda.id,
          estado: encomenda.estadoAtual,
          dataPedido: encomenda.data,
          itens: encomenda.itens,
          metodoPagamento: encomenda.metodoPagamento,
          enderecoEntrega: encomenda.enderecoEntrega,
        ),
      ),
    );
  }
} 