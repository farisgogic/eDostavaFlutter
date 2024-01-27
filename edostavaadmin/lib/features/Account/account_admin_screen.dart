import 'dart:convert';
import 'dart:typed_data';
import 'package:edostavaadmin/common/widgets/custom_button.dart';
import 'package:edostavaadmin/models/korisnik.dart';
import 'package:edostavaadmin/providers/korisnik_provider.dart';
import 'package:flutter/material.dart';
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

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit informacije'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextFieldWithStar(
                      label: 'Ime',
                      onChanged: (value) {
                        newIme = value;
                      },
                      initialValue: korisnik.ime,
                    ),
                    _buildTextFieldWithStar(
                      label: 'Prezme',
                      onChanged: (value) {
                        newPrezime = value;
                      },
                      initialValue: korisnik.prezime,
                    ),
                    _buildTextFieldWithStar(
                      label: 'Email',
                      onChanged: (value) {
                        newEmail = value;
                      },
                      initialValue: korisnik.email,
                    ),
                    _buildTextFieldWithStar(
                      label: 'Naziv restorana',
                      onChanged: (value) {
                        newName = value;
                      },
                      initialValue: restoran.naziv,
                    ),
                    _buildTextFieldWithStar(
                      label: 'Telefon',
                      onChanged: (value) {
                        newTelefon = value;
                      },
                      initialValue: restoran.telefon,
                    ),
                    _buildTextFieldWithStar(
                      label: 'Adresa',
                      onChanged: (value) {
                        newAdresa = value;
                      },
                      initialValue: restoran.adresa,
                    ),
                    _buildTextFieldWithStar(
                      label: 'Radno vrijeme',
                      onChanged: (value) {
                        newRadnoVrijeme = value;
                      },
                      initialValue: restoran.radnoVrijeme,
                    ),
                    _buildTextFieldWithStar(
                      label: 'Opis',
                      onChanged: (value) {
                        newOpis = value;
                      },
                      initialValue: restoran.opis,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        Image.memory(
                          base64Decode(newImagePath),
                          height: 90,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            var pickedImage = await _pickImage();
                            if (pickedImage != null) {
                              newImagePath = pickedImage;
                              setState(() {});
                            }
                          },
                          child: const Text('Zamijeni sliku'),
                        ),
                      ],
                    ),
                  ],
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
                    if (newName.isEmpty ||
                        newTelefon.isEmpty ||
                        newAdresa.isEmpty ||
                        newRadnoVrijeme.isEmpty ||
                        newOpis.isEmpty ||
                        newImagePath.isEmpty ||
                        newIme.isEmpty ||
                        newPrezime.isEmpty ||
                        newEmail.isEmpty) {
                      _showAlertDialog('Popunite sva polja.');
                      return;
                    }
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

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upozorenje'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
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

  Widget _buildTextFieldWithStar({
    required String label,
    required ValueChanged<String> onChanged,
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
        TextField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          controller: TextEditingController(text: initialValue),
          decoration: const InputDecoration(),
        ),
      ],
    );
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
                          fit: BoxFit.fill,
                        )
                      : Image.asset(
                          'assets/images/unknown.png',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.fill,
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
