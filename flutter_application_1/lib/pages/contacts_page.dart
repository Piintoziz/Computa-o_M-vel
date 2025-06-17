import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/pages/message_page.dart';
import 'package:flutter_application_1/pages/orders_page.dart';
import 'dart:async';

import 'package:flutter_application_1/pages/start_talking_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  Timer? _timer;
  List<dynamic> _contacts = [];
  List<dynamic> _filteredContacts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  Future<List<dynamic>> fetchContactNames() async {
    try {
      final currentUID = FirebaseAuth.instance.currentUser?.uid;
      if (currentUID == null) return [];

      final messagesSnapshot = await FirebaseDatabase.instance.ref('messages').get();
      final messages = (messagesSnapshot.value as Map<dynamic, dynamic>).values.toList();
      debugPrint(messages.toString());

      // Get unique user IDs from messages
      final ids = messages
          .whereType<Map>()
          .where((e) => e['from'] == currentUID || e['to'] == currentUID)
          .map((e) => e['from'] == currentUID ? e['to'] : e['from'])
          .where((id) => id != null && id != currentUID)
          .toSet()
          .toList();

      if (ids.isEmpty) return [];

      // Fetch names for each user ID
      final names = await Future.wait(ids.map((id) async {
        final nameSnapshot = await FirebaseDatabase.instance.ref('userdata/$id/name').get();
        return {"name": nameSnapshot.value?.toString() ?? 'Guest', "id": id};
      }));

      return names;
    } catch (e) {
      return [];
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final newContacts = await fetchContactNames();
    if (mounted) {
      setState(() {
        _contacts = newContacts;
        _filteredContacts = newContacts;
        _isLoading = false;
      });
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        final name = contact['name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
    _startTimer();
    _searchController.addListener(() {
      _filterContacts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(BuildContext context, String id, String name) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => MessagePage(otherUserID: id, userName: name)));

  Future<void> _deleteAllMessages(String otherUserId) async {
    try {
      final currentUID = FirebaseAuth.instance.currentUser?.uid;
      if (currentUID == null) return;

      final messagesRef = FirebaseDatabase.instance.ref('messages');
      final messagesSnapshot = await messagesRef.get();
      final messages = (messagesSnapshot.value as Map<dynamic, dynamic>);

      // Create a map of updates to perform
      Map<String, dynamic> updates = {};
      
      // Iterate through messages and mark for deletion if they are between the two users
      messages.forEach((key, value) {
        if (value is Map && 
            ((value['from'] == currentUID && value['to'] == otherUserId) ||
             (value['from'] == otherUserId && value['to'] == currentUID))) {
          updates['$key'] = null; // Set to null to delete
        }
      });

      // Perform the updates
      if (updates.isNotEmpty) {
        await messagesRef.update(updates);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mensagens apagadas com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao apagar mensagens!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes', style: TextStyle(fontWeight: FontWeight.bold)),
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
                hintText: 'Pesquisar contactos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                    ? const Center(child: Text('Sem conversas!'))
                    : ListView.builder(
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final name = _filteredContacts[index]['name'];
                          final id = _filteredContacts[index]['id'];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xff80BAA3),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(name),
                            trailing: PopupMenuButton(
                              itemBuilder: (BuildContext context) { return [
                                PopupMenuItem(child: const Text('Enviar mensagem'), onTap: () => _showMessage(context, id, name)),
                                PopupMenuItem(child: const Text('Encomendas'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage(customerUid: id)))),
                                PopupMenuItem(
                                  child: const Text('Apagar'),
                                  onTap: () => _deleteAllMessages(id),
                                ),
                              ]; },
                              icon: const Icon(Icons.more_vert),
                            ),
                            onTap: () => _showMessage(context, id, name),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StartTalkingPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}