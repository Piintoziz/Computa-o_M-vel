import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({Key? key}) : super(key: key);

  Future<List<String>> fetchContactNames() async {
    try {
      final currentUID = FirebaseAuth.instance.currentUser?.uid;
      if (currentUID == null) return [];

      final messagesSnapshot = await FirebaseDatabase.instance.ref('messages').get();
      final messages = messagesSnapshot.value as List<dynamic>? ?? [];

      debugPrint('messages: $messages');

      // Get unique user IDs from messages
      final ids = messages
          .where((e) => e is Map)
          .map((e) => (e as Map)['from'] == currentUID ? e['to'] : e['from'])
          .where((id) => id != null && id != currentUID)
          .toSet()
          .toList();

      if (ids.isEmpty) return [];

      // Fetch names for each user ID
      final names = await Future.wait(ids.map((id) async {
        final nameSnapshot = await FirebaseDatabase.instance.ref('userdata/$id/name').get();
        return nameSnapshot.value?.toString() ?? 'Guest';
      }));

      names.sort((a, b) => a.compareTo(b));
      return names;
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: FutureBuilder<List<String>>(
        future: fetchContactNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final names = snapshot.data ?? [];
          if (names.isEmpty) {
            return const Center(child: Text('Nenhum contato encontrado.'));
          }
          return ListView.builder(
            itemCount: names.length,
            itemBuilder: (context, index) {
              final name = names[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(name),
              );
            },
          );
        },
      ),
    );
  }
}