import 'package:edostavaadmin/features/Auth/registracija_korisnika_screen.dart';
import 'package:edostavaadmin/providers/korisnik_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_textfield.dart';
import '../../constants/global_variables.dart';
import '../Account/home_admin_screen.dart';

class LoginAdminScreen extends StatefulWidget {
  static const String routeName = '/login-admin-screen';
  const LoginAdminScreen({super.key});

  @override
  State<LoginAdminScreen> createState() => _LoginAdminScreen();
}

class _LoginAdminScreen extends State<LoginAdminScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late KorisnikProvider _korisnikProvider;

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  void _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Greska'),
          content: const Text('Korisnicko ime i lozinka su obavezni.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final dostavljac = await _korisnikProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        HomeAdminScreen.routeName,
        arguments: dostavljac,
      );
    } on Exception {
      if (!mounted) {
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Greska'),
            content: const Text('Pogresno korisnicko ime ili lozinka.'),
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

  @override
  Widget build(BuildContext context) {
    _korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const SizedBox(height: 170),
                    CustomTextField(
                        controller: _usernameController,
                        hintText: 'Korisnicko Ime'),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Lozinka',
                      obscureText: true,
                    ),
                    const SizedBox(height: 150),
                    CustomButton(
                      text: 'Login',
                      onTap: _handleLogin,
                      color: GlobalVariables.buttonColor,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Registracija',
                      onTap: () {
                        Navigator.pushNamed(
                            context, RegistracijaKorisnikaScreen.routeName);
                      },
                      color: GlobalVariables.buttonColor,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
