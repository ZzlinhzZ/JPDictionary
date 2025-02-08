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

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      kanji: map['kanji'],
      written: map['written'],
      pronounced: map['pronounced'],
      glosses: map['glosses'],
    );
  }
}
