import 'dart:convert';

import 'package:flutter/material.dart';

import '../../constants/global_variables.dart';
import '../../constants/websocket.dart';
import '../../models/jelo.dart';
import '../../models/kategorija.dart';
import '../../models/restoran.dart';
import '../../providers/jelakategorija_provider.dart';
import '../../providers/jelo_provider.dart';
import '../../providers/kategorija_providers.dart';
import '../../providers/restoran_provider.dart';

class ArchiveJeloScreen extends StatefulWidget {
  final dynamic userData;
  final WebSocketHandler webSocketHandler;

  const ArchiveJeloScreen({
    Key? key,
    required this.userData,
    required this.webSocketHandler,
  }) : super(key: key);

  @override
  State<ArchiveJeloScreen> createState() =>
      // ignore: no_logic_in_create_state
      _ArchiveJeloScreenState(webSocketHandler: webSocketHandler);
}

class _ArchiveJeloScreenState extends State<ArchiveJeloScreen> {
  final JeloProvider jeloProvider = JeloProvider();
  final KategorijaProvider _kategorijaProvider = KategorijaProvider();
  final JeloKategorijaProvider jeloKategorijaProvider =
      JeloKategorijaProvider();
  final RestoranProvider restoranProvider = RestoranProvider();
  final WebSocketHandler webSocketHandler;

  _ArchiveJeloScreenState({required this.webSocketHandler});

  Restoran? restoran;

  List<Jelo> jela = [];
  List<Kategorija> kategorije = [];

  int _selectedKategorijaIndex = -1;

  loadRestoranInfo() async {
    restoran = await restoranProvider.getById(widget.userData.korisnikId);
  }

  @override
  void initState() {
    super.initState();
    getJela();
    getKategorije();
    loadRestoranInfo();
  }

  @override
  void dispose() {
    webSocketHandler.dispose();
    super.dispose();
  }

  Future<void> getJela() async {
    var searchObject = {
      'RestoranId': widget.userData.korisnikId,
      'Arhivirano': true,
    };

    final result = await jeloProvider.get(searchObject);
    if (mounted) {
      setState(() {
        jela = result;
      });
    }
  }

  Future<void> getKategorije() async {
    var searchObject = {
      'RestoranId': widget.userData.korisnikId,
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
      'RestoranId': widget.userData.korisnikId,
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
            "Arhivirana jela za restoran ${restoran?.naziv ?? ''}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: jela.isEmpty
          ? Center(child: Image.asset('assets/images/nothing-here.jpg'))
          : Column(
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
                  child: ListView.builder(
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
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          _showActivateConfirmationDialog(
                                              jela[index].jeloId);
                                        },
                                        iconSize: 25,
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
    );
  }

  void _showActivateConfirmationDialog(int jeloId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda'),
          content: const Text('Da li ste sigurni da želite aktivirati jelo?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _activateJelo(jeloId);
                Navigator.of(context).pop();
              },
              child: const Text('Activate'),
            ),
          ],
        );
      },
    );
  }

  void _activateJelo(int jeloId) async {
    try {
      Jelo existingJelo = await jeloProvider.getById(jeloId);

      Jelo jelo = Jelo(
        jeloId: existingJelo.jeloId,
        naziv: existingJelo.naziv,
        cijena: existingJelo.cijena,
        opis: existingJelo.opis,
        slika: existingJelo.slika,
        restoranId: existingJelo.restoranId,
        arhivirano: false,
        kategorijaId: existingJelo.kategorijaId,
        ocjena: existingJelo.ocjena,
      );

      await jeloProvider.updateArhivirano(jeloId, jelo);

      getJela();
      webSocketHandler.sendToAllAsync("Podatak je editovan!");
    } catch (e) {
      // ignore: avoid_print
      print("Error activating jelo: $e");
    }
  }
}
