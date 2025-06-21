import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:async';

class MessageNotificationService {
  static final MessageNotificationService _instance = MessageNotificationService._internal();
  factory MessageNotificationService() => _instance;
  MessageNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<DatabaseEvent>? _messagesSubscription;

  Future<void> initialize() async {
    await _initializeLocalNotifications();
    _startListeningToMessages();
  }

  Future<void> _initializeLocalNotifications() async {
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

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _startListeningToMessages() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Listen for new messages where current user is the recipient
    _messagesSubscription = FirebaseDatabase.instance
        .ref('messages')
        .onChildAdded
        .listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final messageData = event.snapshot.value as Map<dynamic, dynamic>;
        final toUserId = messageData['to']?.toString();
        final fromUserId = messageData['from']?.toString();
        final messageText = messageData['text']?.toString() ?? '';

        // Check if this message is for the current user and not from them
        if (toUserId == currentUser.uid && fromUserId != currentUser.uid) {
          _showMessageNotification(messageData);
        }
      }
    });
  }

  Future<void> _showMessageNotification(Map<dynamic, dynamic> messageData) async {
    final fromUserId = messageData['from']?.toString() ?? '';
    final messageText = messageData['text']?.toString() ?? '';

    // Get sender's name
    String senderName = 'Utilizador';
    try {
      final userSnapshot = await FirebaseDatabase.instance
          .ref('userdata/$fromUserId/name')
          .get();
      if (userSnapshot.exists) {
        senderName = userSnapshot.value as String? ?? 'Utilizador';
      }
    } catch (e) {
      print('Error getting sender name: $e');
    }

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
      icon: '@mipmap/ic_launcher',
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

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Nova mensagem de $senderName',
      messageText,
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'message',
        'fromUserId': fromUserId,
        'messageText': messageText,
      }),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Message notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      Map<String, dynamic> data = json.decode(response.payload!);
      if (data['type'] == 'message') {
        // Navigate to messages page
        print('Navigate to messages page from notification');
        // You can implement navigation logic here
      }
    }
  }

  // Method to manually trigger notification for testing
  Future<void> showTestNotification() async {
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

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Teste de Notificação',
      'Esta é uma notificação de teste para verificar se o sistema funciona!',
      platformChannelSpecifics,
    );
  }

  void dispose() {
    _messagesSubscription?.cancel();
  }
} 