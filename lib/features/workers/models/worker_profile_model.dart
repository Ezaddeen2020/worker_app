/// WorkerProfile model - بيانات الملف الشخصي للعامل
import '../../posts/models/project_model.dart';
import '../../reviews/models/review_model.dart';

class WorkerProfile {
  final String id;
  final String userId;
  final String bio;
  final List<String> services;
  final List<Project> projects;
  final List<Review> reviews;
  final double rating;

  WorkerProfile({
    required this.id,
    required this.userId,
    this.bio = '',
    List<String>? services,
    List<Project>? projects,
    List<Review>? reviews,
    double? rating,
  }) : services = services ?? [],
       projects = projects ?? [],
       reviews = reviews ?? [],
       rating = rating ?? 0.0;

  WorkerProfile copyWith({
    String? id,
    String? userId,
    String? bio,
    List<String>? services,
    List<Project>? projects,
    List<Review>? reviews,
    double? rating,
  }) {
    return WorkerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bio: bio ?? this.bio,
      services: services ?? List.from(this.services),
      projects: projects ?? List.from(this.projects),
      reviews: reviews ?? List.from(this.reviews),
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bio': bio,
      'services': services,
      'projects': projects.map((p) => p.toMap()).toList(),
      'reviews': reviews.map((r) => r.toMap()).toList(),
      'rating': rating,
    };
  }

  factory WorkerProfile.fromMap(Map<String, dynamic> map) {
    return WorkerProfile(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      bio: map['bio'] ?? '',
      services: map['services'] != null ? List<String>.from(map['services']) : [],
      projects: map['projects'] != null
          ? List<Project>.from(
              (map['projects'] as List).map((m) => Project.fromMap(Map<String, dynamic>.from(m))),
            )
          : [],
      reviews: map['reviews'] != null
          ? List<Review>.from(
              (map['reviews'] as List).map((m) => Review.fromMap(Map<String, dynamic>.from(m))),
            )
          : [],
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
    );
  }

  /// التحقق من صحة نموذج ملف العامل
  bool isValid() {
    if (id.isEmpty) return false;
    if (userId.isEmpty) return false;
    if (rating < 0.0 || rating > 5.0) return false;
    return true;
  }

  /// التحقق من صحة البيانات وإرجاع جميع الأخطاء
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) errors.add('معرف ملف العامل مطلوب');
    if (userId.isEmpty) errors.add('معرف المستخدم مطلوب');
    if (rating < 0.0 || rating > 5.0) errors.add('التقييم يجب أن يكون بين 0 و 5');
    if (bio.isNotEmpty && bio.length < 3) errors.add('نبذة عن العامل قصيرة جداً');

    return errors;
  }

  @override
  String toString() =>
      'WorkerProfile(id: $id, userId: $userId, projects: ${projects.length}, reviews: ${reviews.length})';
}
