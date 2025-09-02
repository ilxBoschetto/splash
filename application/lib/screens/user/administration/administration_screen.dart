import 'package:application/helpers/user_session.dart';
import 'package:application/models/fontanella.dart';
import 'package:application/models/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  final userSession = UserSession();

  late Future<List<User>> _usersFuture;
  Future<List<Fontanella>>? _fountainsFuture;

  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/users'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((u) => User.fromJson(u)).toList();
    } else {
      throw Exception('Errore nel caricamento utenti');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('${dotenv.env['API_URL']}/users/$id'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _usersFuture = fetchUsers();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore durante l\'eliminazione utente')),
      );
    }
  }

  Future<List<Fontanella>> fetchFountains() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/fontanelle'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((f) => Fontanella.fromJson(f, 0)).toList();
    } else {
      throw Exception('Errore nel caricamento fontanelle');
    }
  }

  Future<void> deleteFountain(String id) async {
    final response = await http.delete(
      Uri.parse('${dotenv.env['API_URL']}/fontanelle/$id'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _fountainsFuture = fetchFountains();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante l\'eliminazione fontanella'),
        ),
      );
    }
  }

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1 && _fountainsFuture == null) {
        _fountainsFuture = fetchFountains();
      }
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'label': 'Utenti', 'icon': Icons.people},
      {'label': 'Fontanelle', 'icon': Icons.local_drink},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('administration'.tr())),
      body: Column(
        children: [
          // Sottomenu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(menuItems.length, (index) {
              final item = menuItems[index];
              final selected = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onMenuTap(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected ? Colors.blue : Colors.grey,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: selected ? Colors.blue : Colors.grey,
                        ),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            color: selected ? Colors.blue : Colors.grey,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          // Contenuto con slide
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) {
                setState(() => _selectedIndex = i);
                if (i == 1 && _fountainsFuture == null) {
                  _fountainsFuture = fetchFountains();
                }
              },
              children: [_buildUsersTab(), _buildFountainsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nessun utente trovato'));
        }

        final users = snapshot.data!;
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = users[index];
            final canDelete = user.email != userSession.email;
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing:
                  canDelete
                      ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteUser(user),
                      )
                      : null,
            );
          },
        );
      },
    );
  }

  Widget _buildFountainsTab() {
    final future = _fountainsFuture;
    if (future == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<List<Fontanella>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nessuna fontanella trovata'));
        }

        final fountains = snapshot.data!;
        return ListView.separated(
          itemCount: fountains.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final fountain = fountains[index];
            return ListTile(
              leading: const Icon(Icons.local_drink),
              title: Text(fountain.nome),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeleteFountain(fountain),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteUser(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('confirm_delete'.tr()),
            content: Text('Vuoi davvero eliminare ${user.name}?'),
            actions: [
              TextButton(
                child: Text('general.cancel'.tr()),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('general.delete'.tr()),
                onPressed: () {
                  Navigator.pop(context);
                  deleteUser(user.id);
                },
              ),
            ],
          ),
    );
  }

  void _confirmDeleteFountain(Fontanella fountain) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('confirm_delete'.tr()),
            content: Text('Vuoi davvero eliminare ${fountain.nome}?'),
            actions: [
              TextButton(
                child: Text('general.cancel'.tr()),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('general.delete'.tr()),
                onPressed: () {
                  Navigator.pop(context);
                  deleteFountain(fountain.id);
                },
              ),
            ],
          ),
    );
  }
}
