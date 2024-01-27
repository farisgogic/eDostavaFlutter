// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:edostavaadmin/models/korisnik.dart';
import 'package:edostavaadmin/providers/korisnik_provider.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/custom_textfield.dart';
import '../../../constants/global_variables.dart';
import '../../common/widgets/custom_button.dart';
import 'login_admin_screen.dart';

class RegistracijaKorisnikaScreen extends StatefulWidget {
  static const String routeName = '/registracija-korisnika-screen';
  const RegistracijaKorisnikaScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<RegistracijaKorisnikaScreen> createState() =>
      _RegistracijaKorisnikaScreenState();
}

class _RegistracijaKorisnikaScreenState
    extends State<RegistracijaKorisnikaScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();
  final _korisnikProvider = KorisnikProvider();
  final _formKey = GlobalKey<FormState>();

  void ocistiFormu() {
    _nameController.clear();
    _lastnameController.clear();
    _usernameController.clear();
    _telefonController.clear();
    _emailController.clear();
    _passwordController.clear();
    _repasswordController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    _lastnameController.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Center(
          child: Text(
            "REGISTRACIJA",
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Ime',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Ime ne može ostati prazno';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _lastnameController,
                        hintText: 'Prezime',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Prezime ne može ostati prazno';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _usernameController,
                        hintText: 'Korisnicko Ime',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Korisnicko ime ne može ostati prazno';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'E-mail',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'E-mail ne može ostati prazan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _telefonController,
                        hintText: 'Broj telefona',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Telefon ne može ostati prazan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Lozinka',
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Lozinka ne može ostati prazna';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _repasswordController,
                        hintText: 'Ponovite lozinku',
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty ||
                              _passwordController.text !=
                                  _repasswordController.text) {
                            return 'Obavezno polje i mora se poklapati sa lozinkom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 100),
                      CustomButton(
                          text: 'REGISTRACIJA',
                          color: GlobalVariables.buttonColor,
                          onTap: () async {
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              final korisnik = Korisnik(
                                ime: _nameController.text,
                                prezime: _lastnameController.text,
                                korisnickoIme: _usernameController.text,
                                email: _emailController.text,
                                telefon: _telefonController.text,
                                lozinka: _passwordController.text,
                                lozinkaPotvrda: _passwordController.text,
                              );
                              await _korisnikProvider.register(korisnik);

                              ocistiFormu();
                              // ignore: use_build_context_synchronously
                              Navigator.pushNamed(
                                  context, LoginAdminScreen.routeName);
                            }
                          }),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, LoginAdminScreen.routeName),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Već imate otvoren račun?',
                              style: TextStyle(color: Colors.black),
                            ),
                            Padding(padding: EdgeInsets.only(left: 7)),
                            Text(
                              'Prijavi se',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
