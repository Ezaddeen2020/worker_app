/// Worker Request Models - نماذج طلبات العمال

/// طلب تحديث بروفايل العامل
class UpdateWorkerProfileRequest {
  final String? profession;
  final String? bio;
  final List<String>? skills;
  final double? hourlyRate;
  final String? location;
  final String? experience;

  UpdateWorkerProfileRequest({
    this.profession,
    this.bio,
    this.skills,
    this.hourlyRate,
    this.location,
    this.experience,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (profession != null) map['profession'] = profession;
    if (bio != null) map['bio'] = bio;
    if (skills != null) map['skills'] = skills;
    if (hourlyRate != null) map['hourly_rate'] = hourlyRate;
    if (location != null) map['location'] = location;
    if (experience != null) map['experience'] = experience;
    return map;
  }

  bool hasChanges() =>
      profession != null ||
      bio != null ||
      skills != null ||
      hourlyRate != null ||
      location != null ||
      experience != null;
}

/// طلب إنشاء بروفايل عامل جديد
class CreateWorkerProfileRequest {
  final String userId;
  final String profession;
  final String bio;
  final List<String> skills;
  final double? hourlyRate;
  final String? location;

  CreateWorkerProfileRequest({
    required this.userId,
    required this.profession,
    required this.bio,
    required this.skills,
    this.hourlyRate,
    this.location,
  });

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'profession': profession,
    'bio': bio,
    'skills': skills,
    if (hourlyRate != null) 'hourly_rate': hourlyRate,
    if (location != null) 'location': location,
  };

  bool isValid() =>
      userId.isNotEmpty && profession.isNotEmpty && bio.isNotEmpty && skills.isNotEmpty;
}

/// طلب البحث عن العمال
class SearchWorkersRequest {
  final String? query;
  final String? profession;
  final String? location;
  final double? minRate;
  final double? maxRate;
  final int page;
  final int limit;

  SearchWorkersRequest({
    this.query,
    this.profession,
    this.location,
    this.minRate,
    this.maxRate,
    this.page = 1,
    this.limit = 20,
  });

  String toQueryString() {
    final params = <String>[];
    if (query != null) params.add('q=$query');
    if (profession != null) params.add('profession=$profession');
    if (location != null) params.add('location=$location');
    if (minRate != null) params.add('min_rate=$minRate');
    if (maxRate != null) params.add('max_rate=$maxRate');
    params.add('page=$page');
    params.add('limit=$limit');
    return params.join('&');
  }
}
