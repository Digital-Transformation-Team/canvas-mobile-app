import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/LocaleProvider.dart';
import '../../../core/overlays/loading_overlay.dart';
import '../data/login_request.dart';
import '../domain/user_class.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late Future<User> _user;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _user = authCheck();
  }

  Future<User> authCheck() async {
    if (await is_authenticated()) {
      return await get_user();
    }
    return User(
      id: 0,
      username: "",
      password: "",
      canvas_web_id: "",
      user_web_id: "",
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.login_success_bar),
          ),
        );
        context.go('/courses');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.login_fail_bar)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.login_title),
        actions: [
          TextButton(
            onPressed: () {
              if (localeProvider.locale.languageCode == 'en') {
                localeProvider.setLocale(Locale('ru'));
              } else {
                localeProvider.setLocale(Locale('en'));
              }
            },
            child: Text(AppLocalizations.of(context)!.next_locale),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20, left: 30, right: 30),
        child: FutureBuilder(
          future: _user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final User? user = snapshot.data;

            if (user != null) {
              _username = user.username;
              _password = user.password;
            }

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _username,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText:
                          AppLocalizations.of(context)!.login_email_placeholder,
                    ),
                    validator: (value) {
                      var validEmail = RegExp(
                        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                      );
                      if (!validEmail.hasMatch(value!)) {
                        return AppLocalizations.of(
                          context,
                        )!.login_email_validator_wrong;
                      }
                      if (value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        )!.login_email_validator_wrong;
                      }
                      _username = value;
                      return null;
                    },
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  TextFormField(
                    initialValue: _password,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText:
                          AppLocalizations.of(
                            context,
                          )!.login_password_placeholder,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText =
                                !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        )!.login_password_validator_empty;
                      }
                      _password = value;
                      return null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: _validateForm,
                      child: Text(
                        AppLocalizations.of(context)!.login_button_text,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
