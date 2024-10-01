import 'dart:convert';
import 'package:edostavaadmin/common/widgets/custom_button.dart';
import 'package:edostavaadmin/common/widgets/custom_textfield.dart';
import 'package:edostavaadmin/models/korisnik.dart';
import 'package:edostavaadmin/providers/korisnik_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/global_variables.dart';
import '../../models/restoran.dart';
import '../../providers/restoran_provider.dart';

class AccountScreen extends StatefulWidget {
  final dynamic userData;

  const AccountScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController imeController = TextEditingController();
  final TextEditingController prezimeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nazivRestoranaController =
      TextEditingController();
  final TextEditingController telefonRestoranaController =
      TextEditingController();
  final TextEditingController lokacijaController = TextEditingController();
  final TextEditingController radnoVrijemeController = TextEditingController();
  final TextEditingController opisController = TextEditingController();

  final RestoranProvider _restoranProvider = RestoranProvider();
  final KorisnikProvider _korisnikProvider = KorisnikProvider();

  List<Restoran> restorani = [];
  late Korisnik korisnik;

  Uint8List? imageBytes;
  Uint8List? newImage;
  String newImagePath = '';

  Future<String?> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        List<int> imageBytesList = await pickedFile.readAsBytes();
        return base64Encode(imageBytesList);
      } else {
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error picking image: $e');
      return null;
    }
  }

  Future<String> _getRestoranImageById(int restoranId) async {
    try {
      final restoran = await _restoranProvider.getById(restoranId);
      return restoran.slika;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting Restoran image: $e');
      rethrow;
    }
  }

  void _showEditDialog(Korisnik korisnik, Restoran restoran) async {
    String newIme = korisnik.ime;
    String newPrezime = korisnik.prezime;
    String newEmail = korisnik.email;
    String newName = restoran.naziv;
    String newTelefon = restoran.telefon;
    String newAdresa = restoran.adresa;
    String newRadnoVrijeme = restoran.radnoVrijeme;
    String newOpis = restoran.opis;
    String newImagePath = await _getRestoranImageById(restoran.restoranId);

    if (restorani.isNotEmpty && restorani[0].slika.isNotEmpty) {
      imageBytes = base64Decode(restorani[0].slika);
    }

    // ignore: no_leading_underscores_for_local_identifiers
    final _formKey = GlobalKey<FormState>();

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit informacije'),
              content: SingleChildScrollView(
                child: Form(
                  // Form widget to manage validation
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      _buildTextFieldWithStar(
                        label: 'Ime',
                        onChanged: (value) {
                          newIme = value;
                        },
                        initialValue: newIme,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Ime je obavezno.';
                          }
                          return null;
                        },
                      ),
                      _buildTextFieldWithStar(
                        label: 'Prezime',
                        onChanged: (value) {
                          newPrezime = value;
                        },
                        initialValue: newPrezime,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Prezime je obavezno.';
                          }
                          return null;
                        },
                      ),
                      _buildTextFieldWithStar(
                        label: 'Email',
                        onChanged: (value) {
                          newEmail = value;
                        },
                        initialValue: newEmail,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email je obavezan.';
                          } else if (!isValidEmail(value)) {
                            return 'Nevažeći email.';
                          }
                          return null;
                        },
                      ),
                      _buildTextFieldWithStar(
                        label: 'Naziv restorana',
                        onChanged: (value) {
                          newName = value;
                        },
                        initialValue: newName,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Naziv restorana je obavezan.';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        label: 'Broj telefona*',
                        controller: telefonRestoranaController,
                        hintText: 'Broj telefona',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            // Maskiranje unosa na osnovu početnih cifara
                            final maskedValue = (newValue.text
                                    .startsWith('060'))
                                ? applyMask(newValue.text,
                                    '###-###-####') // Maskiraj 060 u formatu 060-XXX-XXXX
                                : applyMask(newValue.text,
                                    '###-###-###'); // Maskiraj ostale u formatu XXX-XXX-XXX

                            newTelefon = maskedValue;

                            return TextEditingValue(
                              text: maskedValue,
                              selection: TextSelection.collapsed(
                                  offset: maskedValue.length),
                            );
                          }),
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Telefon ne može ostati prazan';
                          }

                          final phoneNumber = value.replaceAll(RegExp(r'\D'),
                              ''); // Uklanja ne-numeričke karaktere

                          if (!isNumeric(phoneNumber)) {
                            return 'Telefon može sadržavati samo brojeve';
                          }

                          // Validacija za brojeve sa prefiksima 036, 061, 062 (9 cifara)
                          if ((phoneNumber.startsWith('036') ||
                                  phoneNumber.startsWith('061') ||
                                  phoneNumber.startsWith('062')) &&
                              phoneNumber.length == 9) {
                            return null;
                          }
                          // Validacija za brojeve sa prefiksom 060 (10 cifara)
                          else if (phoneNumber.startsWith('060') &&
                              phoneNumber.length == 10) {
                            return null;
                          } else {
                            return 'Nevažeći broj telefona';
                          }
                        },
                      ),
                      _buildTextFieldWithStar(
                        label: 'Adresa',
                        onChanged: (value) {
                          newAdresa = value;
                        },
                        initialValue: newAdresa,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Adresa je obavezna.';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        label: 'Radno vrijeme*',
                        controller: radnoVrijemeController,
                        hintText: 'Radno vrijeme',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final maskedValue =
                                applyMask(newValue.text, '##-##');
                            newRadnoVrijeme = maskedValue;

                            return TextEditingValue(
                              text: maskedValue,
                              selection: TextSelection.collapsed(
                                  offset: maskedValue.length),
                            );
                          }),
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Radno vrijeme ne može ostati prazno';
                          }

                          // Regex za format XX-XX (npr. 08-20)
                          final regExp = RegExp(r'^\d{2}-\d{2}$');
                          if (!regExp.hasMatch(value)) {
                            return 'Nevažeći format radnog vremena. Format treba biti HH-HH';
                          }
                          return null;
                        },
                      ),
                      _buildTextFieldWithStar(
                        label: 'Opis',
                        onChanged: (value) {
                          newOpis = value;
                        },
                        initialValue: newOpis,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Opis je obavezan.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          newImagePath.isNotEmpty
                              ? Image.memory(
                                  base64Decode(newImagePath),
                                  height: 90,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  'assets/images/unknown.png',
                                  height: 90,
                                  fit: BoxFit.contain,
                                ),
                          ElevatedButton(
                            onPressed: () async {
                              var pickedImage = await _pickImage();
                              if (pickedImage != null) {
                                setState(() {
                                  newImagePath = pickedImage;
                                });
                              }
                            },
                            child: const Text('Zamijeni sliku'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Perform the saving operation if the form is valid
                      await _updateRestoranDetails(
                        restoran.restoranId,
                        newName,
                        newTelefon,
                        newAdresa,
                        newRadnoVrijeme,
                        newOpis,
                        newImagePath,
                      );

                      await _korisnikProvider.update(
                        widget.userData.korisnikId,
                        Korisnik(
                          ime: newIme,
                          prezime: newPrezime,
                          email: newEmail,
                          korisnickoIme: korisnik.korisnickoIme,
                          ulogeIdList: korisnik.ulogeIdList,
                        ),
                      );

                      loadUserData();

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Sačuvaj'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextFieldWithStar({
    required String label,
    required ValueChanged<String> onChanged,
    required FormFieldValidator<String> validator, // Added validator parameter
    TextInputType? keyboardType,
    String initialValue = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label*',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          initialValue: initialValue,
          validator: validator, // Assign the validator to the field
          decoration: const InputDecoration(),
        ),
      ],
    );
  }

  void _handleLogout() async {
    try {
      await KorisnikProvider().logout();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login-admin-screen');
    } catch (e) {
      // ignore: avoid_print
      print('Error during logout: $e');
    }
  }

  Future<void> _updateRestoranDetails(
    int restoranId,
    String newName,
    String newTelefon,
    String newAdresa,
    String newRadnoVrijeme,
    String newOpis,
    String newImagePath,
  ) async {
    try {
      final updateRestoran = await _restoranProvider.update(
        restoranId,
        Restoran(
          restoranId: restoranId,
          naziv: newName,
          telefon: newTelefon,
          adresa: newAdresa,
          radnoVrijeme: newRadnoVrijeme,
          opis: newOpis,
          ocjena: restorani[0].ocjena,
          slika: newImagePath,
          korisnikId: restorani[0].korisnikId,
        ),
      );

      setState(() {
        restorani = restorani.map((e) {
          if (e.restoranId == restoranId) {
            return updateRestoran;
          } else {
            return e;
          }
        }).toList();
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error updating Restoran $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    korisnik = await _korisnikProvider.getById(widget.userData.korisnikId);

    imeController.text = korisnik.ime;
    prezimeController.text = korisnik.prezime;
    emailController.text = korisnik.email;

    try {
      restorani = await _restoranProvider.get({
        'korisnikId': widget.userData.korisnikId,
      });

      setState(() {
        nazivRestoranaController.text = restorani[0].naziv;
        telefonRestoranaController.text = restorani[0].telefon;
        lokacijaController.text = restorani[0].adresa;
        radnoVrijemeController.text = restorani[0].radnoVrijeme;
        opisController.text = restorani[0].opis;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching restoran data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.backgroundColor,
        title: Center(
          child: Row(
            children: [
              const Text(
                'Detalji Računa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                    (Set<MaterialState> states) {
                      return GlobalVariables.buttonColor;
                    },
                  ),
                ),
                onPressed: () {
                  _handleLogout();
                },
                child: const Text("Odjavi se",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: imeController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Ime'),
                  ),
                  TextField(
                    controller: prezimeController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Prezime'),
                  ),
                  TextField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const Spacer(),
                  CustomButton(
                    text: "Uredi informacije",
                    color: GlobalVariables.buttonColor,
                    onTap: () {
                      setState(() {
                        _showEditDialog(korisnik, restorani[0]);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nazivRestoranaController,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Naziv restorana'),
                  ),
                  TextField(
                    controller: telefonRestoranaController,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Telefon restorana'),
                  ),
                  TextField(
                    controller: lokacijaController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Lokacija'),
                  ),
                  TextField(
                    controller: radnoVrijemeController,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Radno vrijeme'),
                  ),
                  TextField(
                    controller: opisController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Opis'),
                  ),
                  const Spacer(),
                  restorani.isNotEmpty && restorani[0].slika.isNotEmpty
                      ? Image.memory(
                          base64Decode(restorani[0].slika),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          'assets/images/unknown.png',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}

String applyMask(String value, String mask) {
  final result = StringBuffer();
  var valueIndex = 0;

  for (var i = 0; i < mask.length; i++) {
    final maskChar = mask[i];
    if (maskChar == '#') {
      if (valueIndex < value.length) {
        result.write(value[valueIndex]);
        valueIndex++;
      } else {
        break;
      }
    } else {
      result.write(maskChar);
    }
  }

  return result.toString();
}

bool isValidEmail(String email) {
  final RegExp emailRegex = RegExp(
    r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
  );
  return emailRegex.hasMatch(email);
}

void showInvalidEmailAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Neispravna email adresa'),
        content: const Text('Unesite ispravnu email adresu.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
