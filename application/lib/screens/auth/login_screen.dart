import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../helpers/auth_helper.dart';
import 'package:application/screens/components/minimal_notification.dart';
import 'dart:convert';
import 'package:application/components/loaders.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? error;
  bool loading = false;

  Future<void> login() async {
    setState(() {
      error = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => error = 'Compila tutti i campi');
      return;
    }

    setState(() => loading = true);

    final result = await AuthHelper.login(email, password);

    if (result.success) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() {
        error = result.message;
      });
    }

    setState(() => loading = false);
  }

  void _showSendRecoverPasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          style: TextStyle(color: Colors.white),
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.password),
                          label: const Text("Recupera password"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submitRecoverEmail,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _submitRecoverEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showMinimalNotification(
        context,
        message: 'Inserisci l\'email!',
        duration: 2500,
        position: 'top',
        backgroundColor: Colors.orange,
      );

      return;
    }

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/user/recover-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      showMinimalNotification(
        context,
        message: 'Controlla l\'email per recuperare una nuova password!',
        duration: 2500,
        position: 'bottom',
      );
    } else {
      Navigator.of(context).pop();
      showMinimalNotification(
        context,
        message: 'Qualcosa è andato storto',
        duration: 2500,
        position: 'bottom',
      );
      throw Exception('Errore ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Login",
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Accedi al tuo account',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  TextField(
                    style: TextStyle(color: Colors.white),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    style: TextStyle(color: Colors.white),
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Text(
                          "Password dimenticata?",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () => _showSendRecoverPasswordSheet(),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        child: Text(
                          "Non hai ancora un account?",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: loading ? null : login,
                      child:
                          loading
                              ? const BouncingDotsLoader()
                              : Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
