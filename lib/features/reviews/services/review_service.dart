/// ReviewService - إدارة حفظ واسترجاع التقييمات محلياً
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';

class ReviewService {
  static const String _reviewsKey = 'reviews';

  /// حفظ تقييم جديد
  static Future<bool> saveReview(Review review) async {
    try {
      if (!review.isValid()) {
        print('ReviewService: Invalid review data');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      // Get existing reviews
      List<Review> allReviews = [];
      final reviewsJson = prefs.getString(_reviewsKey);
      if (reviewsJson != null) {
        final List<dynamic> reviewsList = jsonDecode(reviewsJson);
        allReviews = reviewsList.map((e) => Review.fromMap(e)).toList();
      }

      // Check if review already exists
      final existingIndex = allReviews.indexWhere((r) => r.id == review.id);
      if (existingIndex != -1) {
        // Update existing review
        allReviews[existingIndex] = review;
      } else {
        // Add new review
        allReviews.add(review);
      }

      // Save updated list
      final allReviewsMap = allReviews.map((r) => r.toMap()).toList();
      final allReviewsJsonString = jsonEncode(allReviewsMap);
      final result = await prefs.setString(_reviewsKey, allReviewsJsonString);

      print('ReviewService: Saved ${allReviews.length} reviews. Success: $result');
      return result;
    } catch (e) {
      print('${'error'.tr} saving review: $e');
      return false;
    }
  }

  /// استرجاع جميع التقييمات
  static Future<List<Review>> getAllReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsJson = prefs.getString(_reviewsKey);

      if (reviewsJson == null) {
        print('ReviewService: No reviews found in storage');
        return [];
      }

      final List<dynamic> reviewsList = jsonDecode(reviewsJson);
      final reviews = reviewsList.map((e) => Review.fromMap(e)).toList();

      print('ReviewService: Found ${reviews.length} reviews in storage');
      return reviews;
    } catch (e) {
      print('${'error'.tr} retrieving reviews: $e');
      return [];
    }
  }

  /// استرجاع التقييمات لعامل معين
  static Future<List<Review>> getReviewsForWorker(String workerId) async {
    try {
      final allReviews = await getAllReviews();
      final workerReviews = allReviews.where((review) => review.workerId == workerId).toList();

      print('ReviewService: Found ${workerReviews.length} reviews for worker $workerId');
      return workerReviews;
    } catch (e) {
      print('${'error'.tr} retrieving worker reviews: $e');
      return [];
    }
  }

  /// حذف تقييم
  static Future<bool> deleteReview(String reviewId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing reviews
      List<Review> allReviews = [];
      final reviewsJson = prefs.getString(_reviewsKey);
      if (reviewsJson != null) {
        final List<dynamic> reviewsList = jsonDecode(reviewsJson);
        allReviews = reviewsList.map((e) => Review.fromMap(e)).toList();
      }

      // Remove the review with the given ID
      allReviews.removeWhere((review) => review.id == reviewId);

      // Save updated list
      final allReviewsMap = allReviews.map((r) => r.toMap()).toList();
      final allReviewsJsonString = jsonEncode(allReviewsMap);
      final result = await prefs.setString(_reviewsKey, allReviewsJsonString);

      print('ReviewService: Deleted review $reviewId. Remaining reviews: ${allReviews.length}');
      return result;
    } catch (e) {
      print('${'error'.tr} deleting review: $e');
      return false;
    }
  }
}

