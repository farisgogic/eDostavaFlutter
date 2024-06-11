// ignore_for_file: avoid_print

import 'package:edostavaadmin/providers/kategorija_providers.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/Narudzba.dart';
import '../../models/jelo.dart';
import '../../models/kategorija.dart';
import '../../models/restoran.dart';
import '../../providers/jelo_provider.dart';
import '../../providers/narudzba_provider.dart';
import 'package:edostavaadmin/constants/global_variables.dart';

import '../../providers/restoran_provider.dart';

class ReportScreen extends StatefulWidget {
  final dynamic userData;

  const ReportScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final NarudzbaProvider narudzbaProvider = NarudzbaProvider();
  final JeloProvider jeloProvider = JeloProvider();
  final KategorijaProvider _kategorijaProvider = KategorijaProvider();
  final RestoranProvider restoranProvider = RestoranProvider();

  List<Narudzba> narudzbe = [];
  Map<int, String> naziviJela = {};
  List<Jelo> jela = [];
  List<Kategorija> kategorije = [];
  bool isLoading = true;
  bool hasError = false;
  Restoran? restoran;

  int _selectedCategoryId = -1;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      if (restoran == null) {
        await loadRestoran();
      }
      if (restoran != null) {
        await Future.wait<void>(
            [getNarudzbe(), getNaziviJela(), getKategorije()]);
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  loadRestoran() async {
    try {
      var searchObject = {'korisnikId': widget.userData.korisnikId};
      List<Restoran> restaurantList = await restoranProvider.get(searchObject);
      if (restaurantList.isNotEmpty) {
        restoran = restaurantList.first;
        print('restoran id: ${restoran!.restoranId}');
      } else {
        print(
            'No restaurant found for korisnikId: ${widget.userData.korisnikId}');
      }
    } catch (e) {
      print('Error loading restaurant info: $e');
    }
  }

  Future<void> getNarudzbe() async {
    var searchObject = {'RestoranId': restoran!.restoranId};
    final result = await narudzbaProvider.get(searchObject);
    result.sort((a, b) => a.stanje == b.stanje
        ? a.datum.compareTo(b.datum)
        : a.stanje.compareTo(b.stanje));
    setState(() {
      narudzbe = result;
    });
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

  Future<void> getKategorije() async {
    var searchObject = {'RestoranId': restoran!.restoranId};
    final result = await _kategorijaProvider.get(searchObject);
    setState(() {
      kategorije = result;
    });
  }

  Future<void> getNaziviJela() async {
    final jela = await jeloProvider.get({'RestoranId': restoran!.restoranId});
    setState(() {
      naziviJela = {for (var jelo in jela) jelo.jeloId: jelo.naziv};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Izvještaj o narudžbama',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: GlobalVariables.backgroundColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : hasError
                  ? const Text('Error loading data')
                  : ReportContent(
                      narudzbe: narudzbe,
                      kategorije: kategorije,
                      jela: jela,
                      naziviJela: naziviJela,
                      selectedCategoryId: _selectedCategoryId,
                      onCategorySelected: (id) {
                        setState(() {
                          _selectedCategoryId = id;
                        });
                        if (id != -1) {
                          getJeloByKategorijaId(id);
                        } else {
                          getNarudzbe();
                        }
                      },
                      updateNarudzbe: getNarudzbe,
                      getJeloByKategorijaId: getJeloByKategorijaId,
                    ),
        ),
      ),
    );
  }
}

class ReportContent extends StatelessWidget {
  final List<Narudzba> narudzbe;
  final List<Kategorija> kategorije;
  final List<Jelo> jela;
  final Map<int, String> naziviJela;
  final int selectedCategoryId;
  final Function(int) onCategorySelected;
  final Function() updateNarudzbe;
  final Function(int) getJeloByKategorijaId;

  const ReportContent({
    Key? key,
    required this.narudzbe,
    required this.kategorije,
    required this.jela,
    required this.naziviJela,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.updateNarudzbe,
    required this.getJeloByKategorijaId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<int, int> jelaIKolicine = {};

    List<Narudzba> filteredNarudzbe = selectedCategoryId == -1
        ? narudzbe
        : narudzbe.where((narudzba) {
            return narudzba.narudzbaStavke.any(
                (stavka) => jela.any((jelo) => jelo.jeloId == stavka.jeloId));
          }).toList();

    for (var narudzba in filteredNarudzbe) {
      for (var stavka in narudzba.narudzbaStavke) {
        if (selectedCategoryId == -1 ||
            jela.any((jelo) => jelo.jeloId == stavka.jeloId)) {
          if (jelaIKolicine.containsKey(stavka.jeloId)) {
            jelaIKolicine[stavka.jeloId] =
                jelaIKolicine[stavka.jeloId]! + stavka.kolicina;
          } else {
            jelaIKolicine[stavka.jeloId] = stavka.kolicina;
          }
        }
      }
    }

    List<Color> boje = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.brown,
      Colors.pink,
      Colors.teal,
    ];

    List<MapEntry<int, int>> sortedJelaIKolicine = jelaIKolicine.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    double sumValues = sortedJelaIKolicine.isEmpty
        ? 0
        : sortedJelaIKolicine
            .map((e) => e.value)
            .reduce((a, b) => a + b)
            .toDouble();

    List<PieChartSectionData> sections = sumValues == 0
        ? []
        : sortedJelaIKolicine.map((entry) {
            double percent = (entry.value.toDouble() / sumValues) * 100;

            return PieChartSectionData(
              title: '${percent.toStringAsFixed(2)}%',
              value: entry.value.toDouble(),
              color: boje[sortedJelaIKolicine.indexOf(entry) % boje.length],
              radius: 150,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              badgeWidget: null,
              badgePositionPercentageOffset: 1.1,
              titlePositionPercentageOffset: 0.7,
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.5),
                width: 1,
              ),
            );
          }).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 10.0,
          children: kategorije.map((kategorija) {
            return ChoiceChip(
              label: Text(kategorija.naziv),
              selected: selectedCategoryId == kategorija.kategorijaId,
              onSelected: (selected) async {
                onCategorySelected(selected ? kategorija.kategorijaId : -1);
                if (selected) {
                  await getJeloByKategorijaId(kategorija.kategorijaId);
                } else {
                  await updateNarudzbe();
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
              ),
              centerSpaceRadius: 0,
              sectionsSpace: 0,
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: selectedCategoryId == -1
                ? sortedJelaIKolicine.length
                : jela.length,
            itemBuilder: (context, index) {
              int jeloId = selectedCategoryId == -1
                  ? sortedJelaIKolicine[index].key
                  : jela[index].jeloId;
              int kolicina = selectedCategoryId == -1
                  ? sortedJelaIKolicine[index].value
                  : (jelaIKolicine.containsKey(jeloId)
                      ? jelaIKolicine[jeloId]!
                      : 0);
              String jeloNaziv = naziviJela.containsKey(jeloId)
                  ? naziviJela[jeloId]!
                  : 'Nepoznato';

              return Column(
                children: [
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: boje[index % boje.length],
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              jeloNaziv,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Text(
                          'Količina: $kolicina',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                    indent: 10,
                    endIndent: 10,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
