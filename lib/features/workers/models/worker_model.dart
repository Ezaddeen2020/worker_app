// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Worker Model - نموذج العامل/الحرفي
class Worker {
  final String id;
  final String name;
  final String category;
  final String city;
  final int experience;
  final double rating;
  final int reviewsCount;
  final int followersCount;
  final String phone;
  final String whatsapp;
  final String imageUrl;
  final List<String> portfolio;
  final String bio;
  final List<String> reviews; // List of review IDs
  bool isFollowing;

  Worker({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    required this.experience,
    required this.rating,
    required this.reviewsCount,
    required this.followersCount,
    required this.phone,
    required this.whatsapp,
    required this.imageUrl,
    required this.portfolio,
    required this.bio,
    List<String>? reviews,
    this.isFollowing = false,
  }) : reviews = reviews ?? [];

  /// نسخة محدثة من Worker مع إمكانية تغيير أي حقل
  Worker copyWith({
    String? id,
    String? name,
    String? category,
    String? city,
    int? experience,
    double? rating,
    int? reviewsCount,
    int? followersCount,
    String? phone,
    String? whatsapp,
    String? imageUrl,
    List<String>? portfolio,
    String? bio,
    List<String>? reviews,
    bool? isFollowing,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      city: city ?? this.city,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      followersCount: followersCount ?? this.followersCount,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      imageUrl: imageUrl ?? this.imageUrl,
      portfolio: portfolio ?? this.portfolio,
      bio: bio ?? this.bio,
      reviews: reviews ?? this.reviews,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  /// التحقق من صحة نموذج العامل
  bool isValid() {
    if (id.isEmpty) return false;
    if (name.isEmpty || name.length < 2) return false;
    if (category.isEmpty) return false;
    if (city.isEmpty) return false;
    if (experience < 0) return false;
    if (rating < 0.0 || rating > 5.0) return false;
    if (reviewsCount < 0) return false;
    if (followersCount < 0) return false;
    if (phone.isEmpty || phone.length < 10) return false;
    if (whatsapp.isEmpty || whatsapp.length < 10) return false;
    if (imageUrl.isEmpty) return false;
    if (bio.isEmpty) return false;
    return true;
  }

  /// التحقق من صحة البيانات وإرجاع جميع الأخطاء
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) errors.add('معرف العامل مطلوب');
    if (name.isEmpty) errors.add('الاسم مطلوب');
    if (name.length < 2) errors.add('الاسم قصير جداً');
    if (category.isEmpty) errors.add('التصنيف مطلوب');
    if (city.isEmpty) errors.add('المدينة مطلوبة');
    if (experience < 0) errors.add('سنوات الخبرة غير صحيحة');
    if (rating < 0.0 || rating > 5.0) errors.add('التقييم يجب أن يكون بين 0 و 5');
    if (reviewsCount < 0) errors.add('عدد المراجعات غير صحيح');
    if (followersCount < 0) errors.add('عدد المتابعين غير صحيح');
    if (phone.isEmpty) errors.add('رقم الهاتف مطلوب');
    if (phone.length < 10) errors.add('رقم الهاتف غير صحيح');
    if (whatsapp.isEmpty) errors.add('رقم الواتساب مطلوب');
    if (whatsapp.length < 10) errors.add('رقم الواتساب غير صحيح');
    if (imageUrl.isEmpty) errors.add('صورة العامل مطلوبة');
    if (bio.isEmpty) errors.add('نبذة عن العامل مطلوبة');

    return errors;
  }

  @override
  String toString() =>
      'Worker(id: $id, name: $name, category: $category, reviewsCount: $reviewsCount)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'category': category,
      'city': city,
      'experience': experience,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'followersCount': followersCount,
      'phone': phone,
      'whatsapp': whatsapp,
      'imageUrl': imageUrl,
      'portfolio': portfolio,
      'bio': bio,
      'reviews': reviews,
      'isFollowing': isFollowing,
    };
  }

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      city: map['city'] as String,
      experience: map['experience'] as int,
      rating: map['rating'] as double,
      reviewsCount: map['reviewsCount'] as int,
      followersCount: map['followersCount'] as int,
      phone: map['phone'] as String,
      whatsapp: map['whatsapp'] as String,
      imageUrl: map['imageUrl'] as String,
      portfolio: List<String>.from(map['portfolio'] as List<String>),
      bio: map['bio'] as String,
      reviews: map['reviews'] != null ? List<String>.from(map['reviews'] as List<String>) : [],
      isFollowing: map['isFollowing'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Worker.fromJson(String source) =>
      Worker.fromMap(json.decode(source) as Map<String, dynamic>);
}
