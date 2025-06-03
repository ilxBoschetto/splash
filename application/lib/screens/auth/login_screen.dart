import 'package:flutter/material.dart';
import '../../helpers/auth_helper.dart';

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

    final success = await AuthHelper.login(email, password);

    if (success) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() => error = 'Credenziali non valide o errore di rete.');
    }

    setState(() => loading = false);
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
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
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
                              ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              )
                              : Text(
                                'LOGIN',
                                style: (TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                )),
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
