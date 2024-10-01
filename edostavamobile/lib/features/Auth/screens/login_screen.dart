import 'package:edostavamobile/common/widgets/custom_button.dart';
import 'package:edostavamobile/constants/global_variables.dart';
import 'package:edostavamobile/features/Home/home_screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/kupci_provider.dart';

class LogInScreen extends StatefulWidget {
  static const String routeName = '/login-screen';

  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late KupciProvider _kupciProvider;
  final _formKey = GlobalKey<FormState>(); 

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final kupac = await _kupciProvider.login(
            _usernameController.text, _passwordController.text);

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(
          context,
          HomeScreen.routeName,
          arguments: kupac,
        );
      } on Exception {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Greska'),
              content: const Text('Pogrešno korisničko ime ili lozinka.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _kupciProvider = Provider.of<KupciProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Center(
          child: Text(
            "PRIJAVA",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 170),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Korisničko ime',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Korisničko ime je obavezno';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Lozinka',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lozinka je obavezna';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 200),
                  CustomButton(
                    text: 'Login',
                    onTap: _handleLogin,
                    color: GlobalVariables.buttonColor,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
