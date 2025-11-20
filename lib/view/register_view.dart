// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:registration_form/constants/routes.dart';
import 'package:registration_form/services/auth/auth_exceptions.dart';
import 'package:registration_form/services/auth/auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registration Page")),
      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter the email address',
                    ),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Enter the password',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;

                      try {
                        await AuthService.firebase().register(
                          email: email,
                          password: password,
                        );

                        await AuthService.firebase().verifyEmail();

                        if (!mounted) return;

                        Navigator.of(context).pushNamedAndRemoveUntil(
                          verifyRoute,
                          (_) => false,
                        );
                      } on WeakPasswordException {
                        await showErrorDilog(
                          context,
                          "Password must be at least 6 characters.",
                        );
                      } on InvalidEmailException {
                        await showErrorDilog(
                          context,
                          "The email you entered is not valid.",
                        );
                      } on EmailAlreadyUsedException {
                        await showErrorDilog(
                          context,
                          "This email is already registered.",
                        );
                      } on GenericException {
                        await showErrorDilog(
                          context,
                          "Something went wrong.",
                        );
                      } catch (e) {
                        await showErrorDilog(context, e.toString());
                      }
                    },
                    child: const Text("Register"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    },
                    child: const Text("Back to Login"),
                  ),
                ],
              );

            default:
              return const Text("Loading");
          }
        },
      ),
    );
  }
}

Future<void> showErrorDilog(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("An Error Occured!"),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
