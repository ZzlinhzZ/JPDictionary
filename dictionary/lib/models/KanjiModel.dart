class Kanji {
  final int id;
  final String kanji;
  final int? grade; // Có thể null
  final int strokeCount;
  final String? meanings; // Có thể null
  final String? kunReadings; // Có thể null
  final String? onReadings; // Có thể null
  final String? nameReadings; // Có thể null
  final int? jlpt; // Có thể null
  final String unicode;
  final String? heisigEn; // Có thể null

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

  factory Kanji.fromMap(Map<String, dynamic> map) {
    return Kanji(
      id: map['id'],
      kanji: map['kanji'],
      grade: map['grade'] as int?,
      strokeCount: map['stroke_count'],
      meanings: map['meanings'] as String?,
      kunReadings: map['kun_readings'] as String?,
      onReadings: map['on_readings'] as String?,
      nameReadings: map['name_readings'] as String?,
      jlpt: map['jlpt'] as int?,
      unicode: map['unicode'],
      heisigEn: map['heisig_en'] as String?,
    );
  }
}
