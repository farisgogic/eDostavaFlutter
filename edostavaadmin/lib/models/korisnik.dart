class Korisnik {
  final int korisnikId;
  String ime;
  final String prezime;
  final String email;
  final String korisnickoIme;
  final String? telefon;
  final String? lozinka;
  final String? lozinkaPotvrda;
  List<int>? ulogeIdList;

  Korisnik({
    this.korisnikId = 0,
    required this.ime,
    required this.prezime,
    required this.email,
    this.telefon,
    required this.korisnickoIme,
    this.lozinka,
    this.lozinkaPotvrda,
    this.ulogeIdList,
  });

  factory Korisnik.fromJson(Map<String, dynamic> json) {
    return Korisnik(
      korisnikId: json['korisnikId'],
      ime: json['ime'],
      prezime: json['prezime'],
      email: json['email'],
      telefon: json['telefon'],
      korisnickoIme: json['korisnickoIme'],
      lozinka: json['lozinka'],
      lozinkaPotvrda: json['lozinkaPotvrda'],
      ulogeIdList: json['ulogeIdList'] != null
          ? List<int>.from(json['ulogeIdList'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'korisnikId': korisnikId,
      'ime': ime,
      'prezime': prezime,
      'email': email,
      'telefon': telefon,
      'korisnickoIme': korisnickoIme,
      'lozinka': lozinka,
      'lozinkaPotvrda': lozinkaPotvrda,
      'ulogeIdList': ulogeIdList,
    };
  }
}
