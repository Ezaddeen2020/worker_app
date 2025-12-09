/// API Endpoints - نقاط الاتصال بالخادم
class ApiEndpoints {
  // ============= Base URL =============
  // غيّر هذا الرابط عند الاتصال بالـ Backend الحقيقي
  static const String baseUrl = 'https://your-api.com/api';

  // ============= Headers =============
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'Workers-App/1.0',
  };

  static Map<String, String> headersWithToken(String token) {
    return {...headers, 'Authorization': 'Bearer $token'};
  }

  // ============= Auth Endpoints =============
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get validateToken => '$baseUrl/auth/validate-token';

  // ============= User Endpoints =============
  static String get currentUser => '$baseUrl/users/me';
  static String userById(String id) => '$baseUrl/users/$id';
  static String get updateProfile => '$baseUrl/users/profile';
  static String get uploadAvatar => '$baseUrl/users/avatar';
  static String get allUsers => '$baseUrl/users';

  // ============= Worker Profile Endpoints =============
  static String get workerProfiles => '$baseUrl/workers';
  static String workerById(String id) => '$baseUrl/workers/$id';
  static String workerByUserId(String userId) => '$baseUrl/workers/user/$userId';
  static String get updateWorkerProfile => '$baseUrl/workers/profile';

  // ============= Posts/Projects Endpoints =============
  static String get allPosts => '$baseUrl/posts';
  static String postById(String id) => '$baseUrl/posts/$id';
  static String postsByUser(String userId) => '$baseUrl/posts/user/$userId';
  static String get createPost => '$baseUrl/posts';
  static String updatePost(String id) => '$baseUrl/posts/$id';
  static String deletePost(String id) => '$baseUrl/posts/$id';
  static String likePost(String id) => '$baseUrl/posts/$id/like';
  static String unlikePost(String id) => '$baseUrl/posts/$id/unlike';

  // ============= Comments Endpoints =============
  static String commentsByPost(String postId) => '$baseUrl/posts/$postId/comments';
  static String get createComment => '$baseUrl/comments';
  static String commentById(String id) => '$baseUrl/comments/$id';
  static String updateComment(String id) => '$baseUrl/comments/$id';
  static String deleteComment(String id) => '$baseUrl/comments/$id';
  static String deleteAllCommentsByPost(String postId) => '$baseUrl/posts/$postId/comments';
  static String likeComment(String id) => '$baseUrl/comments/$id/like';
  static String unlikeComment(String id) => '$baseUrl/comments/$id/unlike';
  static String repliesByComment(String commentId) => '$baseUrl/comments/$commentId/replies';

  // ============= Reviews Endpoints =============
  static String reviewsByWorker(String workerId) => '$baseUrl/workers/$workerId/reviews';
  static String get createReview => '$baseUrl/reviews';
  static String reviewById(String id) => '$baseUrl/reviews/$id';

  // ============= Search Endpoints =============
  static String searchWorkers(String query) => '$baseUrl/search/workers?q=$query';
  static String searchPosts(String query) => '$baseUrl/search/posts?q=$query';

  // ============= Upload Endpoints =============
  static String get uploadImage => '$baseUrl/upload/image';
  static String get uploadMultipleImages => '$baseUrl/upload/images';
}
