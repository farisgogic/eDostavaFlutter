import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/Narudzba.dart';
import '../../providers/jelo_provider.dart';
import '../../providers/narudzba_provider.dart';
import 'package:edostavaadmin/constants/global_variables.dart';

class ReportScreen extends StatefulWidget {
  final dynamic userData;

  const ReportScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final NarudzbaProvider narudzbaProvider = NarudzbaProvider();
  final JeloProvider jeloProvider = JeloProvider();

  List<Narudzba> narudzbe = [];
  Map<int, String> naziviJela = {};

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

  @override
  void initState() {
    super.initState();
    getNarudzbe();
    getNaziviJela();
  }

  Future<void> getNaziviJela() async {
    final jela =
        await jeloProvider.get({'RestoranId': widget.userData.korisnikId});
    setState(() {
      naziviJela = {for (var jelo in jela) jelo.jeloId: jelo.naziv};
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<int, int> jelaIKolicine = {};

    for (var narudzba in narudzbe) {
      for (var stavka in narudzba.narudzbaStavke) {
        if (jelaIKolicine.containsKey(stavka.jeloId)) {
          jelaIKolicine[stavka.jeloId] =
              jelaIKolicine[stavka.jeloId]! + stavka.kolicina;
        } else {
          jelaIKolicine[stavka.jeloId] = stavka.kolicina;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  itemCount: sortedJelaIKolicine.length,
                  itemBuilder: (context, index) {
                    int jeloId = sortedJelaIKolicine[index].key;
                    int kolicina = sortedJelaIKolicine[index].value;

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
          ),
        ),
      ),
    );
  }
}
