class JeloKategorija {
  int jeloKategorijaId;
  int jeloId;
  int kategorijaId;

  JeloKategorija({
    this.jeloKategorijaId = 0,
    required this.jeloId,
    required this.kategorijaId,
  });

  factory JeloKategorija.fromJson(Map<String, dynamic> json) {
    return JeloKategorija(
      jeloKategorijaId: json['jeloKategorijaId'] ?? 0,
      jeloId: json['jeloId'] ?? 0,
      kategorijaId: json['kategorijaId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jeloKategorijaId': jeloKategorijaId,
      'jeloId': jeloId,
      'kategorijaId': kategorijaId,
    };
  }
}
