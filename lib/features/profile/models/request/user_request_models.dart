/// User Request Models - نماذج طلبات المستخدمين

/// طلب تحديث الملف الشخصي
class UpdateProfileRequest {
  final String? name;
  final String? phone;
  final String? bio;
  final String? imagePath;

  UpdateProfileRequest({this.name, this.phone, this.bio, this.imagePath});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (phone != null) map['phone'] = phone;
    if (bio != null) map['bio'] = bio;
    if (imagePath != null) map['image_path'] = imagePath;
    return map;
  }

  bool hasChanges() => name != null || phone != null || bio != null || imagePath != null;
}

/// طلب رفع الصورة الشخصية
class UploadAvatarRequest {
  final String imagePath;

  UploadAvatarRequest({required this.imagePath});

  Map<String, dynamic> toMap() => {'image': imagePath};

  bool isValid() => imagePath.isNotEmpty;
}

/// طلب البحث عن مستخدمين
class SearchUsersRequest {
  final String query;
  final int page;
  final int limit;

  SearchUsersRequest({required this.query, this.page = 1, this.limit = 20});

  String toQueryString() => 'q=$query&page=$page&limit=$limit';
}
