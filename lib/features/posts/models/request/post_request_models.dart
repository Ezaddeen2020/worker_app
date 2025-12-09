/// Post Request Models - نماذج طلبات المنشورات

/// نموذج إنشاء منشور
class CreatePostRequest {
  final String title;
  final String description;
  final List<String> images;
  final double? price;

  CreatePostRequest({
    required this.title,
    required this.description,
    required this.images,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'images': images,
      if (price != null) 'price': price,
    };
  }

  bool isValid() {
    return title.isNotEmpty && description.isNotEmpty;
  }
}

/// نموذج تحديث منشور
class UpdatePostRequest {
  final String postId;
  final String? title;
  final String? description;
  final List<String>? images;
  final double? price;

  UpdatePostRequest({required this.postId, this.title, this.description, this.images, this.price});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (images != null) map['images'] = images;
    if (price != null) map['price'] = price;
    return map;
  }

  bool hasChanges() {
    return title != null || description != null || images != null || price != null;
  }
}

/// نموذج طلب لايك
class LikeRequest {
  final String postId;
  final String userId;

  LikeRequest({required this.postId, required this.userId});

  Map<String, dynamic> toMap() {
    return {'post_id': postId, 'user_id': userId};
  }
}
