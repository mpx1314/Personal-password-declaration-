class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? website;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.website,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  // 从数据库创建对象
  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      website: map['website'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      tags: (map['tags'] as String? ?? '').split(',').where((t) => t.isNotEmpty).toList(),
    );
  }

  // 转换为数据库格式
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags.join(','),
    };
  }

  // 创建副本
  PasswordEntry copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  // 转换为JSON（用于导出）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
    };
  }

  // 从JSON创建（用于导入）
  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      website: json['website'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  String toString() {
    return 'PasswordEntry(id: $id, title: $title, username: $username, website: $website)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}