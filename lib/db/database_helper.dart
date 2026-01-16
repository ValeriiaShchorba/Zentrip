import 'dart:convert'; // JSON işlemleri için
import 'package:flutter/services.dart'; // Dosya okuma (rootBundle) için
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/place.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('zentrip.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType =
        'INTEGER NOT NULL'; // SQLite'da boolean yoktur, 0 veya 1 kullanılır

    // 1. Tabloyu Oluştur
    await db.execute('''
      CREATE TABLE places ( 
        id $idType, 
        title $textType,
        description $textType,
        city $textType,
        country $textType,
        imageUrl $textType,
        category $textType,
        isFavorite $boolType,
        isVisited $boolType
      )
    ''');

    // 2. Verileri JSON dosyasından yükle
    await _seedDatabase(db);
  }

  // --- YENİ EKLENEN FONKSİYON ---
  Future<void> _seedDatabase(Database db) async {
    try {
      // JSON dosyasını oku
      String jsonString = await rootBundle.loadString(
        'assets/data/places.json',
      );
      List<dynamic> placesList = jsonDecode(jsonString);

      // Batch (Toplu İşlem) başlat - Performans için çok önemlidir
      Batch batch = db.batch();

      for (var placeData in placesList) {
        // placeData bir Map'tir (JSON nesnesi)
        batch.insert('places', placeData);
      }

      await batch.commit(noResult: true);
      debugPrint("✅ Veritabanı JSON'dan başarıyla dolduruldu!");
    } catch (e) {
      debugPrint("❌ Veri yükleme hatası: $e");
    }
  }

  // --- DİĞER FONKSİYONLARIN AYNEN KALIYOR ---

  Future<List<Place>> getAllPlaces() async {
    final db = await instance.database;
    final result = await db.query('places');
    return result.map((json) => Place.fromMap(json)).toList();
  }

  Future<List<Place>> getUniqueCountries() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT * FROM places GROUP BY country');
    return result.map((json) => Place.fromMap(json)).toList();
  }

  Future<List<Place>> getCitiesByCountry(String country) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT * FROM places WHERE country = ? GROUP BY city',
      [country],
    );
    return result.map((json) => Place.fromMap(json)).toList();
  }

  Future<List<Place>> getPlacesByCity(String city) async {
    final db = await instance.database;
    final result = await db.query(
      'places',
      where: 'city = ?',
      whereArgs: [city],
    );
    return result.map((json) => Place.fromMap(json)).toList();
  }

  Future<List<Place>> getFavorites() async {
    final db = await instance.database;
    final result = await db.query(
      'places',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return result.map((json) => Place.fromMap(json)).toList();
  }

  Future<List<Place>> getVisitedPlaces() async {
    final db = await instance.database;
    final result = await db.query(
      'places',
      where: 'isVisited = ?',
      whereArgs: [1],
    );
    return result.map((json) => Place.fromMap(json)).toList();
  }

  Future<int> updatePlace(Place place) async {
    final db = await instance.database;
    return db.update(
      'places',
      place.toMap(),
      where: 'id = ?',
      whereArgs: [place.id],
    );
  }
}
