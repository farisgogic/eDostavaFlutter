import 'package:edostavaadmin/providers/korisnik_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../common/widgets/custom_button.dart';
import '../../constants/global_variables.dart';
import '../Account/home_admin_screen.dart';
import 'registracija_korisnika_screen.dart';

class LoginAdminScreen extends StatefulWidget {
  static const String routeName = '/login-admin-screen';
  const LoginAdminScreen({super.key});

  @override
  State<LoginAdminScreen> createState() => _LoginAdminScreenState();
}

class _LoginAdminScreenState extends State<LoginAdminScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late KorisnikProvider _korisnikProvider;

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dostavljac = await _korisnikProvider.login(
          _usernameController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          HomeAdminScreen.routeName,
          arguments: dostavljac,
        );
      } on Exception {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pogrešno korisničko ime ili lozinka.')),
        );
      }
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
