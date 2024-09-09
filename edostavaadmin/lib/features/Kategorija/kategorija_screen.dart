// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:edostavaadmin/constants/global_variables.dart';
import 'package:edostavaadmin/models/korisnik.dart';
import 'package:edostavaadmin/providers/kategorija_providers.dart';
import 'package:edostavaadmin/providers/korisnik_provider.dart';
import 'package:flutter/material.dart';

import '../../constants/websocket.dart';
import '../../models/kategorija.dart';
import '../../models/restoran.dart';
import '../../providers/jelakategorija_provider.dart';
import '../../providers/restoran_provider.dart';

class KategorijaScreen extends StatefulWidget {
  final dynamic userData;
  final WebSocketHandler webSocketHandler;

  const KategorijaScreen(
      {Key? key, required this.userData, required this.webSocketHandler})
      : super(key: key);

  @override
  State<KategorijaScreen> createState() =>
      // ignore: no_logic_in_create_state
      _KategorijaScreenState(webSocketHandler: webSocketHandler);
}

class _KategorijaScreenState extends State<KategorijaScreen> {
  final KategorijaProvider kategorijaProvider = KategorijaProvider();
  final JeloKategorijaProvider jeloKategorijaProvider =
      JeloKategorijaProvider();
  final RestoranProvider restoranProvider = RestoranProvider();
  final KorisnikProvider korisnikProvider = KorisnikProvider();

  final WebSocketHandler webSocketHandler;

  _KategorijaScreenState({required this.webSocketHandler});

  List<Kategorija> kategorije = [];
  Restoran? restoran;
  Korisnik? korisnik;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    await loadRestoranInfo();
    await loadRestoran();
    getKategorije();
  }

  @override
  void dispose() {
    webSocketHandler.dispose();
    super.dispose();
  }

  loadRestoranInfo() async {
    try {
      korisnik = await korisnikProvider.getById(widget.userData.korisnikId);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading restaurant info: $e');
    }
  }

  loadRestoran() async {
    try {
      var searchObject = {'korisnikId': widget.userData.korisnikId};
      List<Restoran> restaurantList = await restoranProvider.get(searchObject);
      if (restaurantList.isNotEmpty) {
        restoran = restaurantList.first;
      } else {
        print(
            'No restaurant found for korisnikId: ${widget.userData.korisnikId}');
      }
    } catch (e) {
      print('Error loading restaurant info: $e');
    }
  }

  Future<void> getKategorije() async {
    if (restoran != null) {
      var searchObject = {
        'RestoranId': restoran!.restoranId,
      };
      final result = await kategorijaProvider.get(searchObject);

      if (mounted) {
        setState(() {
          kategorije = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.backgroundColor,
        title: Center(
          child: Text(
            "Kategorije za restoran ${korisnik?.korisnickoIme ?? ''}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: kategorije.isEmpty
                  ? Center(
                      child: Image.asset(
                        'assets/images/nothing-here.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : ListView.builder(
                      itemCount: kategorije.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              kategorije[index].naziv,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditKategorijaDialog(
                                        kategorije[index]);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                        kategorije[index].kategorijaId);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddKategorijaDialog();
        },
        tooltip: 'Dodaj kategoriju',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showAddKategorijaDialog() async {
    String newName = '';
    bool isValid = true;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dodaj Kategoriju'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newName = value;
                },
                decoration: const InputDecoration(labelText: 'Naziv'),
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
                setState(() {
                  isValid = newName.isNotEmpty;
                });

                if (isValid) {
                  await _addNewKategorija(newName);
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('GREŠKA'),
                        content: const Text('Naziv ne moze biti prazan.'),
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
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewKategorija(String newName) async {
    try {
      final newKategorija = await kategorijaProvider.insert(
        Kategorija(naziv: newName, restoranId: restoran!.restoranId),
      );

      setState(() {
        kategorije.add(newKategorija);
      });
      getKategorije();

      webSocketHandler.sendToAllAsync("Novi podatak je dodan!");
      // ignore: empty_catches
    } catch (e) {}
  }

  void _showEditKategorijaDialog(Kategorija kategorija) async {
    String newName = kategorija.naziv;
    bool isValid = true;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Kategorija'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newName = value;
                },
                controller: TextEditingController(text: kategorija.naziv),
                decoration: const InputDecoration(labelText: 'Naziv'),
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
                setState(() {
                  isValid = newName.isNotEmpty;
                });

                if (isValid) {
                  await _updateKategorijaName(kategorija.kategorijaId, newName);
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Naziv ne moze biti prazan.'),
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
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateKategorijaName(int kategorijaId, String newName) async {
    try {
      if (newName.isNotEmpty) {
        final updatedKategorija = await kategorijaProvider.update(
          kategorijaId,
          Kategorija(naziv: newName, restoranId: restoran!.restoranId),
        );

        getKategorije();
        setState(() {
          kategorije = kategorije.map((k) {
            if (k.kategorijaId == kategorijaId) {
              return updatedKategorija;
            } else {
              return k;
            }
          }).toList();

          webSocketHandler.sendToAllAsync("Podatak je editovan!");
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('GREŠKA'),
              content: const Text('Naziv ne moze biti prazan.'),
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
    // ignore: empty_catches
    } catch (e) {
    }
  }

  Future<void> _deleteKategorija(int kategorijaId) async {
    try {
      final jelaWithKategorija = await jeloKategorijaProvider.get({
        'kategorijaId': kategorijaId,
      });

      if (jelaWithKategorija.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Greska prilikom brisanja kategorija'),
              content: const Text(
                  'Ne mozete izbrisati kategoriju, jer postoje proizvodi sa tom kategorijom!'),
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
      } else {
        await kategorijaProvider.deleteKategorija(kategorijaId);
        getKategorije();
        webSocketHandler.sendToAllAsync("Podatak je izbrisan!");
        setState(() {
          kategorije.removeWhere((k) => k.kategorijaId == kategorijaId);
        });
      }
    } catch (e) {
      print('Error deleting Kategorija: $e');
    }
  }

  void _showDeleteConfirmationDialog(int kategorijaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda'),
          content:
              const Text('Da li ste sigurni da želite izbrisati kategoriju?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteKategorija(kategorijaId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
