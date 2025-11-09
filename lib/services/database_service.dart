import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_entry.dart';
import 'secure_storage_service.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'passwords.db';
  static const int _databaseVersion = 1;

  static const String _tableName = 'password_entries';

  // 表结构
  static const String _createTableSQL = '''
    CREATE TABLE $_tableName (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      website TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      tags TEXT
    )
  ''';

  static Future<void> init() async {
    if (_database != null) return;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createTableSQL);
    // 创建索引
    await db.execute('CREATE INDEX idx_title ON $_tableName(title)');
    await db.execute('CREATE INDEX idx_website ON $_tableName(website)');
    await db.execute('CREATE INDEX idx_tags ON $_tableName(tags)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
    if (oldVersion < 2) {
      // 未来版本升级逻辑
    }
  }

  // 插入密码条目
  static Future<String> insertPasswordEntry(PasswordEntry entry) async {
    final db = _database!;
    final encryptionKey = await SecureStorageService.getEncryptionKey();

    // 加密敏感数据
    final encryptedPassword = SecureStorageService.encryptData(entry.password, encryptionKey);
    final encryptedUsername = SecureStorageService.encryptData(entry.username, encryptionKey);

    final encryptedEntry = entry.copyWith(
      password: encryptedPassword,
      username: encryptedUsername,
    );

    await db.insert(_tableName, encryptedEntry.toMap());
    return encryptedEntry.id;
  }

  // 获取所有密码条目
  static Future<List<PasswordEntry>> getAllPasswordEntries() async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    final encryptionKey = await SecureStorageService.getEncryptionKey();

    return maps.map((map) {
      // 解密数据
      final decryptedPassword = SecureStorageService.decryptData(map['password'], encryptionKey);
      final decryptedUsername = SecureStorageService.decryptData(map['username'], encryptionKey);

      final decryptedMap = Map<String, dynamic>.from(map);
      decryptedMap['password'] = decryptedPassword;
      decryptedMap['username'] = decryptedUsername;

      return PasswordEntry.fromMap(decryptedMap);
    }).toList();
  }

  // 根据ID获取密码条目
  static Future<PasswordEntry?> getPasswordEntryById(String id) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final encryptionKey = await SecureStorageService.getEncryptionKey();

    // 解密数据
    final decryptedPassword = SecureStorageService.decryptData(maps[0]['password'], encryptionKey);
    final decryptedUsername = SecureStorageService.decryptData(maps[0]['username'], encryptionKey);

    final decryptedMap = Map<String, dynamic>.from(maps[0]);
    decryptedMap['password'] = decryptedPassword;
    decryptedMap['username'] = decryptedUsername;

    return PasswordEntry.fromMap(decryptedMap);
  }

  // 搜索密码条目
  static Future<List<PasswordEntry>> searchPasswordEntries(String query) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'title LIKE ? OR website LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );

    final encryptionKey = await SecureStorageService.getEncryptionKey();

    return maps.map((map) {
      // 解密数据
      final decryptedPassword = SecureStorageService.decryptData(map['password'], encryptionKey);
      final decryptedUsername = SecureStorageService.decryptData(map['username'], encryptionKey);

      final decryptedMap = Map<String, dynamic>.from(map);
      decryptedMap['password'] = decryptedPassword;
      decryptedMap['username'] = decryptedUsername;

      return PasswordEntry.fromMap(decryptedMap);
    }).toList();
  }

  // 更新密码条目
  static Future<int> updatePasswordEntry(PasswordEntry entry) async {
    final db = _database!;
    final encryptionKey = await SecureStorageService.getEncryptionKey();

    // 加密敏感数据
    final encryptedPassword = SecureStorageService.encryptData(entry.password, encryptionKey);
    final encryptedUsername = SecureStorageService.encryptData(entry.username, encryptionKey);

    final encryptedEntry = entry.copyWith(
      password: encryptedPassword,
      username: encryptedUsername,
      updatedAt: DateTime.now(),
    );

    return await db.update(
      _tableName,
      encryptedEntry.toMap(),
      where: 'id = ?',
      whereArgs: [encryptedEntry.id],
    );
  }

  // 删除密码条目
  static Future<int> deletePasswordEntry(String id) async {
    final db = _database!;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取密码条目数量
  static Future<int> getPasswordEntriesCount() async {
    final db = _database!;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 批量导入密码条目
  static Future<void> importPasswordEntries(List<PasswordEntry> entries) async {
    final db = _database!;
    final batch = db.batch();

    final encryptionKey = await SecureStorageService.getEncryptionKey();

    for (final entry in entries) {
      // 加密敏感数据
      final encryptedPassword = SecureStorageService.encryptData(entry.password, encryptionKey);
      final encryptedUsername = SecureStorageService.encryptData(entry.username, encryptionKey);

      final encryptedEntry = entry.copyWith(
        password: encryptedPassword,
        username: encryptedUsername,
      );

      batch.insert(_tableName, encryptedEntry.toMap());
    }

    await batch.commit();
  }

  // 清空所有数据
  static Future<void> clearAllPasswordEntries() async {
    final db = _database!;
    await db.delete(_tableName);
  }

  // 关闭数据库
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}