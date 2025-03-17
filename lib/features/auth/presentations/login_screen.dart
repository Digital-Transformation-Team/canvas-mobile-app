import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/overlays/loading_overlay.dart';
import '../data/login_request.dart';
import '../domain/user_class.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  var _username;
  var _password;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    authCheck();
  }

  void authCheck() async {
    if (await is_authenticated())
      context.go('/courses');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateForm() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      LoadingOverlay.show(context);
      User? user = await login(context, _username, _password);
      LoadingOverlay.hide();
      if (user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful')));
        context.go('/courses');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.only(top: 20, left: 30, right: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your username',
                ),
                validator: (value) {
                  var validEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                  if (!validEmail.hasMatch(value!)) {
                    return 'Use valid email';
                  }
                  if (value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onChanged:
                    (value) => setState(() {
                      _username = value;
                    }),
              ),
              Padding(padding: EdgeInsets.all(10)),
              TextFormField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText; // Переключаем состояние
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onChanged:
                    (value) => setState(() {
                      _password = value;
                    }),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _validateForm,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
