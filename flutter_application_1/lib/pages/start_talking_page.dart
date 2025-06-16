import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/message_page.dart';

class StartTalkingPage extends StatefulWidget {
  const StartTalkingPage({super.key});

  @override
  State<StartTalkingPage> createState() => _StartTalkingPageState();
}

class _StartTalkingPageState extends State<StartTalkingPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUID = FirebaseAuth.instance.currentUser?.uid;
      if (currentUID == null) return;

      final usersSnapshot = await FirebaseDatabase.instance.ref('userdata').get();
      if (usersSnapshot.value == null) return;

      final users = usersSnapshot.value as Map<dynamic, dynamic>;
      final results = <Map<String, dynamic>>[];

      users.forEach((key, value) {
        if (key == currentUID) return; // Skip current user
        
        if (value is Map) {
          final name = value['name']?.toString().toLowerCase() ?? '';
          final email = value['email']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          if (name.contains(searchQuery) || email.contains(searchQuery)) {
            results.add({
              'id': key,
              'name': value['name'] ?? 'Guest',
              'email': value['email'] ?? '',
            });
          }
        }
      });

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao procurar utilizadores')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Conversa', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Procurar por nome ou email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _searchUsers,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Escreva um nome ou email para procurar'
                              : 'Nenhum utilizador encontrado',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xff80BAA3),
                              child: Text(
                                user['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            title: Text(user['name']),
                            subtitle: Text(
                              user['email'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessagePage(
                                    otherUserID: user['id'],
                                    userName: user['name'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}