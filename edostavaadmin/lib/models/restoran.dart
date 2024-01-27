class Restoran {
  final int restoranId;
  final String naziv;
  final String telefon;
  final String adresa;
  final String radnoVrijeme;
  final String opis;
  final double? ocjena;
  String slika;
  final int korisnikId;

  Restoran({
    required this.restoranId,
    required this.naziv,
    required this.telefon,
    required this.adresa,
    required this.radnoVrijeme,
    required this.opis,
    required this.ocjena,
    required this.slika,
    required this.korisnikId,
  });

  factory Restoran.fromJson(Map<String, dynamic> json) {
    return Restoran(
      restoranId: json['restoranId'],
      naziv: json['naziv'],
      telefon: json['telefon'],
      adresa: json['adresa'],
      radnoVrijeme: json['radnoVrijeme'],
      opis: json['opis'],
      ocjena: json['ocjena']?.toDouble(),
      slika: json['slika'],
      korisnikId: json['korisnikId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restoranId': restoranId,
      'naziv': naziv,
      'telefon': telefon,
      'adresa': adresa,
      'radnoVrijeme': radnoVrijeme,
      'opis': opis,
      'ocjena': ocjena,
      'slika': slika,
      'korisnikId': korisnikId,
    };
  }
}
