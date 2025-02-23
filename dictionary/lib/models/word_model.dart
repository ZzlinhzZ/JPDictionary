class Word {
  final int id;
  final String kanji;
  final String written;
  final String pronounced;
  final String glosses;

  Word({
    required this.id,
    required this.kanji,
    required this.written,
    required this.pronounced,
    required this.glosses,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      kanji: json['kanji'],
      written: json['written'],
      pronounced: json['pronounced'],
      glosses: json['glosses'],
    );
  }
}
