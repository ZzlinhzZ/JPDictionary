class Kanji {
  final int id;
  final String kanji;
  final int grade;
  final int strokeCount;
  final String meanings;
  final String kunReadings;
  final String onReadings;
  final String nameReadings;
  final int jlpt;
  final String unicode;
  final String heisigEn;

  Kanji({
    required this.id,
    required this.kanji,
    required this.grade,
    required this.strokeCount,
    required this.meanings,
    required this.kunReadings,
    required this.onReadings,
    required this.nameReadings,
    required this.jlpt,
    required this.unicode,
    required this.heisigEn,
  });

  factory Kanji.fromMap(Map<String, dynamic> map) {
    return Kanji(
      id: map['id'],
      kanji: map['kanji'],
      grade: map['grade'],
      strokeCount: map['stroke_count'],
      meanings: map['meanings'],
      kunReadings: map['kun_readings'],
      onReadings: map['on_readings'],
      nameReadings: map['name_readings'],
      jlpt: map['jlpt'],
      unicode: map['unicode'],
      heisigEn: map['heisig_en'],
    );
  }
}
