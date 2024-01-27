import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/global_variables.dart';
import '../../constants/websocket.dart';
import '../../models/Narudzba.dart';
import '../../models/restoran.dart';
import '../../providers/narudzba_provider.dart';
import '../../providers/restoran_provider.dart';

class NarudzbaScreen extends StatefulWidget {
  final dynamic userData;

  const NarudzbaScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<NarudzbaScreen> createState() => _NarudzbaScreenState();
}

class _NarudzbaScreenState extends State<NarudzbaScreen> {
  final NarudzbaProvider narudzbaProvider = NarudzbaProvider();

  final RestoranProvider restoranProvider = RestoranProvider();

  Restoran? restoran;
  List<Narudzba> narudzbe = [];

  WebSocketHandler webSocketHandler =
      WebSocketHandler('ws://localhost:7068/api');

  @override
  void initState() {
    super.initState();
    loadRestoranInfo();
    getNarudzbe();

    webSocketHandler.onMessage.listen((message) {
      print('Stigla poruka sa servera: $message');
      if (mounted) {
        loadRestoranInfo();
        getNarudzbe();
      }
    });
  }

  loadRestoranInfo() async {
    restoran = await restoranProvider.getById(widget.userData.korisnikId);
  }

  Future<void> getNarudzbe() async {
    var searchObject = {
      'RestoranId': widget.userData.korisnikId,
    };

    final result = await narudzbaProvider.get(searchObject);

    result.sort((a, b) {
      if (a.stanje == b.stanje) {
        return a.datum.compareTo(b.datum);
      }
      return a.stanje.compareTo(b.stanje);
    });

    setState(() {
      narudzbe = result;
    });
  }

  Future<void> updateOrderStatus(Narudzba narudzba) async {
    if (narudzba.stanje == 0) {
      try {
        await narudzbaProvider.updateNarudzba(narudzba.narudzbaId, 1);
        getNarudzbe();
      } catch (e) {
        // ignore: avoid_print
        print('Failed to update order status: $e');
      }
    }
  }

  Future<void> orderReady(Narudzba narudzba) async {
    if (narudzba.stanje == 1) {
      try {
        await narudzbaProvider.updateNarudzba(narudzba.narudzbaId, 2);
        getNarudzbe();
      } catch (e) {
        // ignore: avoid_print
        print('Failed to update order status: $e');
      }
    }
  }

  double izracunajUkupnaCijena(Narudzba narudzba) {
    double ukupnaCijena = 0;
    for (var stavka in narudzba.narudzbaStavke) {
      ukupnaCijena += stavka.cijena;
    }
    return ukupnaCijena;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.backgroundColor,
        title: Center(
            child: Text(
          "Narudžbe za restoran ${restoran?.naziv ?? ''}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: narudzbe.length,
                itemBuilder: (context, index) {
                  final narudzba = narudzbe[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Broj narudžbe: ${narudzba.brojNarudzbe}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Column(
                                children: [
                                  Text(
                                    'Status: ${narudzba.stanjeTekst}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Visibility(
                                    visible: narudzba.stanje == 0,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          updateOrderStatus(narudzba),
                                      child: const Text('Prihvati narudzbu'),
                                    ),
                                  ),
                                  Visibility(
                                    visible: narudzba.stanje == 1,
                                    child: ElevatedButton(
                                      onPressed: () => orderReady(narudzba),
                                      child: const Text('Narudzba spremna'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Datum: ${DateFormat('dd-MM-yyyy hh:mm').format(narudzba.datum)}'),
                          const SizedBox(height: 8),
                          const Text(
                            'Stavke narudžbe:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: narudzba.narudzbaStavke.length,
                            itemBuilder: (context, index) {
                              final stavka = narudzba.narudzbaStavke[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(stavka.naziv)),
                                    Text('Količina: ${stavka.kolicina}'),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Cijena: ${stavka.cijena / stavka.kolicina} KM'),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'Ukupna cijena: ${izracunajUkupnaCijena(narudzba)} KM',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
    );
  }
}
