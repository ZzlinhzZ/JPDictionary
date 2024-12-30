# JPDictionary
# Database:
   TABLE kanji ( bảng này là bảng kanji
        id INTEGER PRIMARY KEY,
        kanji TEXT,
        grade INTEGER,
        stroke_count INTEGER,
        meanings TEXT,
        kun_readings TEXT,
        on_readings TEXT,
        name_readings TEXT,
        jlpt INTEGER,
        unicode TEXT,
        heisig_en TEXT
    )
  
  TABLE words_Test ( bảng này là bảng từ vựng
        id INTEGER PRIMARY KEY,
        kanji TEXT,
        written TEXT,
        pronounced TEXT,
        glosses TEXT
    )
