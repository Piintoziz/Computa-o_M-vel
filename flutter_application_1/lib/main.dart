import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/publicar_anuncio_page.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'routes/app_routes.dart';
import 'pages/detalhes_encomenda_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  /* FireBase stuff */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  /* Main: */
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      if (user == null) {
        // O utilizado não está autenticado
        _navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => WelcomePage(),
          ),
        );
      } else {
        // O utilizado está autenticado
        _navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => const PublicarAnuncioPage(),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Farmer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D5A)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.welcome,
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
