import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/contacts_page.dart';
import '../pages/welcome_page.dart';
import '../pages/login_page.dart';
import '../pages/create_account_page.dart';
import '../pages/home_navigation.dart';
import '../pages/proximas_entregas_page.dart';
import '../pages/publicar_anuncio_page.dart';
import '../pages/gestao_Encomendas.dart';
import '../pages/detalhes_encomenda_page.dart';
import '../pages/gestao_encomendas_Faturacao.dart';
import '../pages/menu_gestao.dart';
import '../pages/menu_principal.dart';
import '../pages/gestao_encomendas_emitir_fatura.dart';
import '../pages/gestao_encomendas_compras_abandonadas.dart';
import '../pages/analise_dados_page.dart';
import '../pages/minha_banca_page.dart';
import '../pages/products_page.dart';
import '../pages/maps_page.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String home = '/';
  static const String proximasEntregas = '/proximas-entregas';
  static const String publicarAnuncio = '/publicar-anuncio';
  static const String gestaoEncomendas = '/gestao-encomendas';
  static const String detalhesEncomenda = '/detalhes-encomenda';
  static const String gestaoEncomendasFaturacao = '/gestao-encomendas-faturacao';
  static const String menuGestao = '/menu-gestao';
  static const String menuPrincipal = '/menu-principal';
  static const String gestaoEncomendasEmitirFatura = '/gestao-encomendas-emitir-fatura';
  static const String gestaoEncomendasComprasAbandonadas = '/gestao-encomendas-compras-abandonadas';
  static const String analiseDados = '/analise-dados';
  static const String contacts = '/contacts';
  static const String minhaBanca = '/minha-banca';
  static const String products = '/produtos';
  static const String maps = '/maps';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => WelcomePage(),
      login: (context) => LoginPage(),
      createAccount: (context) => const CreateAccountPage(),
      home: (context) => const HomeNavigation(),
      proximasEntregas: (context) => const ProximasEntregasPage(),
      publicarAnuncio: (context) => PublicarAnuncioPage(
        onPublishSuccess: () => Navigator.pop(context),
        onBackToIndex: () => Navigator.pop(context),
      ),
      gestaoEncomendas: (context) => GestaoEncomendasPage(
        onBack: () => Navigator.pop(context),
      ),
      gestaoEncomendasFaturacao: (context) => const GestaoEncomendasFaturacaoPage(),
      menuGestao: (context) => const MenuGestao(),
      menuPrincipal: (context) => const MainMenu(),
      gestaoEncomendasEmitirFatura: (context) => const GestaoEncomendasEmitirFaturaPage(),
      gestaoEncomendasComprasAbandonadas: (context) => const GestaoEncomendasComprasAbandonadasPage(),
      analiseDados: (context) => AnaliseDadosPage(),
      contacts: (context) => ContactsPage(),
      minhaBanca: (context) => const MinhaBancaPage(),
      products: (context) => const ProductsPage(),
      maps: (context) => const MapsPage(),
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