import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key, required this.otherUserID, required this.userName});

  final String userName;
  final String otherUserID;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  List<Map<String, dynamic>> messages = [];
  bool _isLoading = true;

  Future<void> _fetchMessages() async {
    try {
      final currentUID = FirebaseAuth.instance.currentUser?.uid;
      if (currentUID == null) return;

      final messagesSnapshot = await FirebaseDatabase.instance.ref('messages').get();
      final allMessages = (messagesSnapshot.value as Map<dynamic, dynamic>? ?? {});

      final filteredMessages = allMessages.entries
          .where((entry) {
            final message = entry.value as Map<dynamic, dynamic>;
            return (message['from'] == currentUID && message['to'] == widget.otherUserID) ||
                   (message['from'] == widget.otherUserID && message['to'] == currentUID);
          })
          .map((entry) {
            final message = entry.value as Map<dynamic, dynamic>;
            return {
              'fromMe': message['from'] == currentUID,
              'text': message['text']?.toString() ?? '',
              'timestamp': message['timestamp'] ?? 0,
            };
          })
          .toList();

      // Sort messages by timestamp
      filteredMessages.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

      if (mounted) {
        setState(() {
          messages = filteredMessages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final currentUID = FirebaseAuth.instance.currentUser?.uid;
      if (currentUID == null) return;

      final messagesRef = FirebaseDatabase.instance.ref('messages').push();
      await messagesRef.set({
        'from': currentUID,
        'to': widget.otherUserID,
        'text': text,
        'timestamp': ServerValue.timestamp,
      });

      _messageController.clear();
      await _fetchMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar mensagem!')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchMessages();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF185C37),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xff80BAA3),
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.userName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_msgs.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg['fromMe'] as bool;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFFD2F8C6) : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isMe ? 18 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 18),
                                ),
                              ),
                              child: Text(
                                msg['text'],
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Escreva uma mensagem...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}