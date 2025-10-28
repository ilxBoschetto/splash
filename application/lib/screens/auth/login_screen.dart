import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../helpers/auth_helper.dart';
import 'package:application/screens/components/minimal_notification.dart';
import 'dart:convert';
import 'package:application/screens/components/loaders.dart';

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
      setState(() => error = 'warnings.fill_in_fields'.tr());
      return;
    }

    setState(() => loading = true);

    final result = await AuthHelper.login(email, password);

    if (result.success) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            style: TextStyle(color: Colors.white),
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'general.email'.tr(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.password),
                            label: Text('recover_password'.tr()),
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
          ),
    );
  }

  void _submitRecoverEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showMinimalNotification(
        context,
        message: 'insert_email'.tr(),
        duration: 2500,
        position: 'top',
        backgroundColor: Colors.orange,
      );

      return;
    }

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/users/recover-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      showMinimalNotification(
        context,
        message: 'check_email_to_recover_password'.tr(),
        duration: 2500,
        position: 'bottom',
        backgroundColor: Colors.green,
      );
    } else {
      Navigator.of(context).pop();
      showMinimalNotification(
        context,
        message: 'errors.something_went_wrong'.tr(),
        duration: 2500,
        position: 'bottom',
        backgroundColor: Colors.orange,
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
          'general.login'.tr(),
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
            color: Theme.of(context).colorScheme.surface,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'login_with_account'.tr(),
                    style: theme.textTheme.headlineSmall,
                  ),
                  /*
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                      child: Image.asset('assets/images/google.png', width: 35),
                    ),
                    label: Text(
                      'Accedi con Google',
                      style: TextStyle(
                        color: Theme.of(context).iconTheme.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      final result = await AuthHelper.loginWithGoogle();
                      if (result.success) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (_) => false,
                        );
                      } else {
                        setState(() => error = result.message);
                      }
                    },
                  ),
                  */
                  const SizedBox(height: 16),
                  Divider(),
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
                    decoration: InputDecoration(
                      labelText: 'general.email'.tr(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    style: TextStyle(color: Colors.white),
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'general.password'.tr(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Text(
                          '${'forgot_password'.tr()}?',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () => _showSendRecoverPasswordSheet(),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        child: Text(
                          '${'do_not_have_an_account'.tr()}?',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
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
                                'general.login'.tr().toUpperCase(),
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
