class SavedKanji {
  final int? id;
  final String kanji;
  final String pronounced;
  final String meaning;

  SavedKanji({
    this.id,
    required this.kanji,
    required this.pronounced,
    required this.meaning,
  });

  // Chuyển đổi từ Map (SQLite) sang Object
  factory SavedKanji.fromMap(Map<String, dynamic> map) {
    return SavedKanji(
      id: map['id'],
      kanji: map['kanji'],
      pronounced: map['pronounced'] ?? '',
      meaning: map['meaning'] ?? '',
    );
  }

  // Chuyển đổi từ Object sang Map (để lưu vào SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kanji': kanji,
      'pronounced': pronounced,
      'meaning': meaning,
    };
  }
}
