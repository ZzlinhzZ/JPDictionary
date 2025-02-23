# JPDictionary
1. chạy server ở JDictionaryServer

2. Cài các thư viện cần thiết
```
flutter pub get
```

3. Chỉnh sửa địa chỉ api ở file 
```
lib/services/api_service.dart
``` 
thay 192.168.1.9 bằng địa chỉ Ipv4 trong Wireless LAN adapter Wi-Fi (ipconfig)

4. Chạy ứng dụng (có thể chạy web và android)
```
flutter run
```




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
