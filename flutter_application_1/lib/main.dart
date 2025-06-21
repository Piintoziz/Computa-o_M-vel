import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'pages/detalhes_encomenda_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/message_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  print('Handling a background message: ${message.messageId}');
  
  // Show local notification for background messages
  final FlutterLocalNotificationsPlugin localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Initialize local notifications for background
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await localNotifications.initialize(initializationSettings);
  
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'messages_channel',
    'Mensagens',
    channelDescription: 'Canal para notificações de mensagens',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    playSound: true,
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await localNotifications.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    message.notification?.title ?? 'Nova Mensagem',
    message.notification?.body ?? 'Você recebeu uma nova mensagem',
    platformChannelSpecifics,
  );
}

Future<void> main() async {
  /* FireBase stuff */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
