import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key, required this.userId, required this.otherUserID});

  final String userId;
  final String otherUserID;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  // MOCKED DATA - CHANGE TO FIREBASE FETCH LATER
  final String otherUsername = "Pedro Matias"; // TODO: FETCH USERNAME FROM FIREBASE USING otherUserID
  final List<Map<String, dynamic>> messages = [ //TODO: FETCH MESSAGES FROM FIREBASE USING userId and otherUserID
    {
      'fromMe': false,
      'text': 'Bom dia!\nEstava a precisar de umas batats para a minha sopa, ainda tem algumas disponiveis?'
    },
    {
      'fromMe': true,
      'text': 'Bom dia!\nSim tenho basta fazer uma encomenda e em poucos dias recebe-a.'
    },
    {
      'fromMe': false,
      'text': 'Muito obrigado Sr Agricultor'
    },
  ];

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
              backgroundColor: const Color(0xff80BAA3), //Maybe change the color later
              child: Text(
                otherUsername.isNotEmpty ? otherUsername[0] : '',
              style: TextStyle(color: Theme.of(context).colorScheme.primary,  fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              otherUsername,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background leaves
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
                child: ListView.builder(
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
                          style: TextStyle(
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {}, // TODO: IMPLEMENT SEND
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