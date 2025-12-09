/// Project model - نموذج المشروع أو العمل

class Project {
  final String id;
  final String workerId;
  final String title;
  final String description;
  final int likes;
  final List<String> likedBy;
  final List<String> images;
  final double? price;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.workerId,
    required this.title,
    required this.description,
    List<String>? images,
    int? likes,
    List<String>? likedBy,
    this.price,
    DateTime? createdAt,
  }) : images = images ?? [],
       likes = likes ?? 0,
       likedBy = likedBy ?? [],
       createdAt = createdAt ?? DateTime.now();

  Project copyWith({
    String? id,
    String? workerId,
    String? title,
    String? description,
    List<String>? images,
    int? likes,
    List<String>? likedBy,
    double? price,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? List.from(this.images),
      likes: likes ?? this.likes,
      likedBy: likedBy ?? List.from(this.likedBy),
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workerId': workerId,
      'title': title,
      'description': description,
      'likes': likes,
      'likedBy': likedBy,
      'images': images,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      workerId: map['workerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      images: map['images'] != null ? List<String>.from(map['images']) : [],
      likes: (map['likes'] is int)
          ? map['likes'] as int
          : (map['likes'] is num ? (map['likes'] as num).toInt() : 0),
      likedBy: map['likedBy'] != null ? List<String>.from(map['likedBy']) : [],
      price: map['price'] is num ? (map['price'] as num).toDouble() : null,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// التحقق من صحة نموذج المشروع
  bool isValid() {
    if (id.isEmpty) return false;
    if (workerId.isEmpty) return false;
    if (title.isEmpty) return false;
    if (description.isEmpty) return false;
    if (likes < 0) return false;
    if (price != null && price! < 0) return false;
    return true;
  }

  /// التحقق من صحة البيانات وإرجاع جميع الأخطاء
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) errors.add('معرف المشروع مطلوب');
    if (workerId.isEmpty) errors.add('معرف العامل مطلوب');
    if (title.isEmpty) errors.add('عنوان المشروع مطلوب');
    if (title.length < 3) errors.add('عنوان المشروع قصير جداً');
    if (description.isEmpty) errors.add('وصف المشروع مطلوب');
    if (description.length < 10) errors.add('وصف المشروع قصير جداً');
    if (likes < 0) errors.add('عدد الإعجابات غير صحيح');
    if (price != null && price! < 0) errors.add('السعر غير صحيح');

    return errors;
  }

  @override
  String toString() => 'Project(id: $id, title: $title)';
}
