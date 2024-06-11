// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:edostavaadmin/models/jelo.dart';
import 'package:edostavaadmin/providers/jelakategorija_provider.dart';
import 'package:edostavaadmin/providers/jelo_provider.dart';
import 'package:edostavaadmin/providers/kategorija_providers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/global_variables.dart';
import '../../constants/websocket.dart';
import '../../models/jelokategorija.dart';
import '../../models/kategorija.dart';
import '../../models/korisnik.dart';
import '../../models/restoran.dart';
import '../../providers/korisnik_provider.dart';
import '../../providers/restoran_provider.dart';

class JeloScreen extends StatefulWidget {
  final dynamic userData;
  final WebSocketHandler webSocketHandler;

  const JeloScreen({
    Key? key,
    required this.userData,
    required this.webSocketHandler,
  }) : super(key: key);

  @override
  State<JeloScreen> createState() =>
      // ignore: no_logic_in_create_state
      _JeloScreenState(webSocketHandler: webSocketHandler);
}

class _JeloScreenState extends State<JeloScreen> {
  final JeloProvider jeloProvider = JeloProvider();
  final WebSocketHandler webSocketHandler;

  _JeloScreenState({required this.webSocketHandler});
  final KategorijaProvider _kategorijaProvider = KategorijaProvider();
  final JeloKategorijaProvider jeloKategorijaProvider =
      JeloKategorijaProvider();
  final RestoranProvider restoranProvider = RestoranProvider();
  final KorisnikProvider korisnikProvider = KorisnikProvider();

  Restoran? restoran;
  Korisnik? korisnik;

  List<Jelo> jela = [];
  List<Kategorija> kategorije = [];

  int _selectedKategorijaIndex = -1;

  loadRestoranInfo() async {
    try {
      korisnik = await korisnikProvider.getById(widget.userData.korisnikId);
      var searchObject = {'korisnikId': widget.userData.korisnikId};
      List<Restoran> restaurantList = await restoranProvider.get(searchObject);
      if (restaurantList.isNotEmpty) {
        restoran = restaurantList.first;
        print('restoran id: ${restoran!.restoranId}');
      } else {
        print(
            'No restaurant found for korisnikId: ${widget.userData.korisnikId}');
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading restaurant info: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    await loadRestoranInfo();
    await getJela();
    await getKategorije();
  }

  @override
  void dispose() {
    webSocketHandler.dispose();
    super.dispose();
  }

  Future<void> getJela() async {
    var searchObject = {
      'RestoranId': restoran!.restoranId,
      'Arhivirano': false,
    };

    final result = await jeloProvider.get(searchObject);
    if (mounted) {
      setState(() {
        jela = result;
      });
    }
  }

  Future<String> _getJeloImageById(int jeloId) async {
    try {
      final jelo = await jeloProvider.getById(jeloId);
      return jelo.slika;
    } catch (e) {
      print('Error getting Jelo image: $e');
      rethrow;
    }
  }

  Future<void> getKategorije() async {
    var searchObject = {
      'RestoranId': restoran!.restoranId,
    };
    final result = await _kategorijaProvider.get(searchObject);
    if (mounted) {
      setState(() {
        kategorije = result;
      });
    }
  }

  Future<void> getJeloByKategorijaId(int kategorijaId) async {
    var searchObject = {
      'RestoranId': restoran!.restoranId,
      'KategorijaId': kategorijaId,
    };

    final result = await jeloProvider.get(searchObject);
    setState(() {
      jela = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.backgroundColor,
        title: Center(
          child: Text(
            "Jela za restoran ${korisnik?.korisnickoIme ?? ''}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kategorije.length,
              itemBuilder: (BuildContext context, int index) {
                final kategorija = kategorije[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ChoiceChip(
                    selected: _selectedKategorijaIndex == index,
                    onSelected: (selected) {
                      setState(() {
                        _selectedKategorijaIndex = selected ? index : -1;
                      });
                      if (selected) {
                        getJeloByKategorijaId(kategorija.kategorijaId);
                      } else {
                        setState(() {
                          _selectedKategorijaIndex = -1;
                        });
                        getJela();
                      }
                    },
                    label: Text(kategorija.naziv.toUpperCase()),
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: GlobalVariables.backgroundColor,
                    selectedColor: GlobalVariables.buttonColor,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: jela.isEmpty
                ? Center(
                    child: Image.asset(
                      'assets/images/nothing-here.jpg',
                      fit: BoxFit.cover,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: jela.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          elevation: 5,
                          child: SizedBox(
                            height: 150,
                            child: ListTile(
                              title: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        jela[index].naziv,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(jela[index].opis),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Cijena: ${jela[index].cijena.toString()} KM'),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Ocjena: ${jela[index].ocjena.toString()}'),
                                    ],
                                  ),
                                  const Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showEditJeloDialog(jela[index]);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  jela[index].jeloId);
                                            },
                                          ),
                                        ],
                                      ),
                                      Image.memory(
                                        base64Decode(jela[index].slika),
                                        height: 90,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: kategorije.isNotEmpty
            ? () => _showAddJeloDialog()
            : _showNoKategorijeDialog,
        tooltip:
            kategorije.isNotEmpty ? 'Dodaj jelo' : 'No available kategorije',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showEditJeloDialog(Jelo jelo) async {
    String newName = jelo.naziv;
    String newOpis = jelo.opis;
    double newCijena = jelo.cijena;
    String newImagePath = await _getJeloImageById(jelo.jeloId);

    List<JeloKategorija> jeloKategorije = await jeloKategorijaProvider.get({
      'jeloId': jelo.jeloId,
    });

    int selectedKategorijaId =
        kategorije.isNotEmpty ? jeloKategorije[0].kategorijaId : -1;

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Jelo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextFieldWithStar(
                    label: 'Naziv jela*',
                    onChanged: (value) {
                      newName = value;
                    },
                    initialValue: newName,
                  ),
                  _buildTextFieldWithStar(
                    label: 'Cijena*',
                    onChanged: (value) {
                      newCijena = double.tryParse(value) ?? jelo.cijena;
                    },
                    keyboardType: TextInputType.number,
                    initialValue: newCijena.toString(),
                  ),
                  _buildTextFieldWithStar(
                    label: 'Opis*',
                    onChanged: (value) {
                      newOpis = value;
                    },
                    maxLines: 3,
                    initialValue: newOpis,
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<int>(
                    value: selectedKategorijaId,
                    hint: const Text('Select Kategorija'),
                    onChanged: (int? value) {
                      setState(() {
                        selectedKategorijaId = value ?? -1;
                      });
                    },
                    items: kategorije
                        .map((kategorija) => DropdownMenuItem<int>(
                              value: kategorija.kategorijaId,
                              child: Text(kategorija.naziv),
                            ))
                        .toList(),
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
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (newName.isEmpty) {
                      _showAlertDialog('Naziv jela je obavezan.');
                      return;
                    } else if (newCijena <= 0) {
                      _showAlertDialog('Unesite cijenu veću od 0 KM.');
                      return;
                    } else if (newImagePath.isEmpty) {
                      _showAlertDialog('Slika jela je obavezna.');
                      return;
                    } else if (newOpis.isEmpty) {
                      _showAlertDialog('Opis jela je obavezan.');
                      return;
                    }

                    await _updateJeloDetails(
                      jelo.jeloId,
                      newName,
                      newOpis,
                      newCijena,
                      newImagePath,
                      selectedKategorijaId,
                    );
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

  Future<void> _updateJeloDetails(
    int jeloId,
    String newName,
    String newOpis,
    double newCijena,
    String newImagePath,
    int selectedKategorijaId,
  ) async {
    try {
      final jeloKategorije = await jeloKategorijaProvider.get({
        'jeloId': jeloId,
      });

      if (jeloKategorije.isNotEmpty) {
        final existingJeloKategorija = jeloKategorije[0];

        // ignore: unnecessary_null_comparison
        if (existingJeloKategorija != null) {
          final currentlyId = existingJeloKategorija.kategorijaId;

          if (currentlyId != selectedKategorijaId) {
            final jeloKategorije = await jeloKategorijaProvider.get({
              'jeloId': jeloId,
              'kategorijaId': currentlyId,
            });

            if (jeloKategorije.isNotEmpty) {
              final jeloKategorijaId = jeloKategorije[0].jeloKategorijaId;

              await jeloKategorijaProvider.update(
                jeloKategorijaId,
                jeloId,
                selectedKategorijaId,
              );
            }
          }
        }
      }

      final updatedJelo = await jeloProvider.update(
        jeloId,
        Jelo(
          naziv: newName,
          opis: newOpis,
          cijena: newCijena,
          restoranId: restoran!.restoranId,
          slika: newImagePath,
          kategorijaId: [selectedKategorijaId],
        ),
      );

      getJela();
      setState(() {
        jela = jela.map((j) {
          if (j.jeloId == jeloId) {
            return updatedJelo;
          } else {
            return j;
          }
        }).toList();
        webSocketHandler.sendToAllAsync("Podatak je editovan!");
      });
      _selectedKategorijaIndex =
          kategorije.indexWhere((k) => k.kategorijaId == selectedKategorijaId);
      getJeloByKategorijaId(selectedKategorijaId);
    } catch (e) {
      print('Error updating Jelo: $e');
    }
  }

  void _showAddJeloDialog() async {
    String newJeloName = '';
    double newJeloPrice = 0.0;
    String newJeloDescription = '';
    String newJeloImageUrl = '';
    int selectedKategorijaId =
        kategorije.isNotEmpty ? kategorije[0].kategorijaId : -1;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Dodaj Jelo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                children: [
                  _buildTextFieldWithStar(
                    label: 'Naziv jela',
                    onChanged: (value) {
                      newJeloName = value;
                    },
                    initialValue: newJeloName,
                  ),
                  _buildTextFieldWithStar(
                    label: 'Cijena',
                    onChanged: (value) {
                      newJeloPrice = double.tryParse(value) ?? 0.0;
                    },
                    keyboardType: TextInputType.number,
                    initialValue: newJeloPrice.toString(),
                  ),
                  _buildTextFieldWithStar(
                    label: 'Opis',
                    onChanged: (value) {
                      newJeloDescription = value;
                    },
                    maxLines: 2,
                    initialValue: newJeloDescription,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Izaberite kategoriju',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<int>(
                    value: selectedKategorijaId,
                    onChanged: (int? value) {
                      setState(() {
                        selectedKategorijaId = value ?? -1;
                      });
                    },
                    items: kategorije
                        .map((kategorija) => DropdownMenuItem<int>(
                              value: kategorija.kategorijaId,
                              child: Text(kategorija.naziv),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      newJeloImageUrl.isNotEmpty
                          ? Image.memory(
                              base64Decode(newJeloImageUrl),
                              height: 90,
                            )
                          : Container(
                              height: 90,
                              color: Colors.grey,
                            ),
                      ElevatedButton(
                        onPressed: () async {
                          var pickedImage = await _pickImage();
                          if (pickedImage != null) {
                            setState(() {
                              newJeloImageUrl = pickedImage;
                            });
                          }
                        },
                        child: const Text('Izaberite sliku'),
                      ),
                    ],
                  ),
                ],
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
                    if (newJeloName.isEmpty) {
                      _showAlertDialog('Naziv jela je obavezan.');
                      return;
                    } else if (newJeloPrice <= 0) {
                      _showAlertDialog('Unesite cijenu veću od 0 KM.');
                      return;
                    } else if (newJeloImageUrl.isEmpty) {
                      _showAlertDialog('Slika jela je obavezna.');
                      return;
                    } else if (newJeloDescription.isEmpty) {
                      _showAlertDialog('Opis jela je obavezan.');
                      return;
                    }

                    await _addNewJelo(
                      newJeloName,
                      newJeloPrice,
                      newJeloDescription,
                      newJeloImageUrl,
                      selectedKategorijaId,
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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
    int maxLines = 1,
    TextInputType? keyboardType,
    String initialValue = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label*',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextField(
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: keyboardType,
          controller: TextEditingController(text: initialValue),
          decoration: const InputDecoration(),
        ),
      ],
    );
  }

  Future<void> _addNewJelo(
    String newJeloName,
    double newJeloPrice,
    String newJeloDescription,
    String newJeloImageUrl,
    int selectedKategorijaId,
  ) async {
    List<String> errorMessages = [];

    if (newJeloName.isEmpty) {
      errorMessages.add('Naziv je obavezan.');
    }

    if (newJeloPrice <= 0) {
      errorMessages.add('Cijena mora biti veća od 0.');
    }

    if (newJeloDescription.isEmpty) {
      errorMessages.add('Opis je obavezan.');
    }

    if (newJeloImageUrl.isEmpty) {
      errorMessages.add('Slika je obavezna.');
    }

    if (errorMessages.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Greška'),
            content: Column(
              children: errorMessages.map((message) => Text(message)).toList(),
            ),
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
      return;
    }

    try {
      final newJelo = await jeloProvider.insert(
        Jelo(
          naziv: newJeloName,
          cijena: newJeloPrice,
          opis: newJeloDescription,
          restoranId: restoran!.restoranId,
          slika: newJeloImageUrl,
          kategorijaId: [selectedKategorijaId],
        ),
      );

      final newJeloId = newJelo.jeloId;

      final newJeloKategorija = JeloKategorija(
        jeloId: newJeloId,
        kategorijaId: selectedKategorijaId,
      );

      await jeloKategorijaProvider.insert(newJeloKategorija);
      setState(() {
        jela.add(newJelo);
      });
      webSocketHandler.sendToAllAsync("Novi podatak je dodan!");
    } catch (e) {
      print('Error adding new Jelo: $e');
    }
    getJela();
  }

  Future<String?> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        List<int> imageBytes = await pickedFile.readAsBytes();
        return base64Encode(imageBytes);
      } else {
        return null;
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<void> _deleteJelo(int jeloId) async {
    try {
      await jeloProvider.deleteJelo(jeloId);
      setState(() {
        jela.removeWhere((k) => k.jeloId == jeloId);
      });
      getJela();
      webSocketHandler.sendToAllAsync("Podatak je arhiviran!");
    } catch (e) {
      print('Greska prilikom arhiviranja jela: $e');
    }
  }

  void _showDeleteConfirmationDialog(int jeloId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda'),
          content: const Text('Da li ste sigurni da želite arhivirati jelo?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteJelo(jeloId);
                Navigator.of(context).pop();
              },
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );
  }

  void _showNoKategorijeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('GREŠKA'),
          content: const Text(
              'Prvo morate dodati kategoriju, da bi dodali novo jelo!'),
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
}
