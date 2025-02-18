class Kanji {
  final int id;
  final String kanji;
  final int? grade;
  final int strokeCount;
  final String? meanings;
  final String? kunReadings;
  final String? onReadings;
  final String? nameReadings;
  final int? jlpt;
  final String unicode;
  final String? heisigEn;

  Kanji({
    required this.id,
    required this.kanji,
    this.grade,
    required this.strokeCount,
    this.meanings,
    this.kunReadings,
    this.onReadings,
    this.nameReadings,
    this.jlpt,
    required this.unicode,
    this.heisigEn,
  });

  factory Kanji.fromJson(Map<String, dynamic> json) {
    return Kanji(
      id: json['id'],
      kanji: json['kanji'],
      grade: json['grade'],
      strokeCount: json['stroke_count'],
      meanings: json['meanings'],
      kunReadings: json['kun_readings'],
      onReadings: json['on_readings'],
      nameReadings: json['name_readings'],
      jlpt: json['jlpt'],
      unicode: json['unicode'],
      heisigEn: json['heisig_en'],
    );
  }
}
