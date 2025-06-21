import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'pages/detalhes_encomenda_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/message_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  /* FireBase stuff */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification services
  await NotificationService().initialize();
  await MessageNotificationService().initialize();

  /* Main: */
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
