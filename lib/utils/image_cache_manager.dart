import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  /// Cache for local files to avoid reloading from disk repeatedly
  final Map<String, MemoryImage> _localImageCache = {};

  /// Get a cached local image or load it from file
  Future<ImageProvider> getCachedLocalImage(String filePath) async {
    // Return cached image if available
    if (_localImageCache.containsKey(filePath)) {
      return _localImageCache[filePath]!;
    }

    // Load image from file
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final image = MemoryImage(bytes);
        _localImageCache[filePath] = image;
        return image;
      }
    } catch (e) {
      print('Error loading local image: $e');
    }

    // Return default placeholder if loading fails
    return const AssetImage('assets/placeholder.png');
  }

  /// Clear the local image cache
  void clearLocalImageCache() {
    _localImageCache.clear();
  }

  /// Preload images to cache
  Future<void> preloadImages(List<String> filePaths) async {
    for (final path in filePaths) {
      try {
        await getCachedLocalImage(path);
      } catch (e) {
        print('Error preloading image $path: $e');
      }
    }
  }

  /// Get cache directory for the app
  Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Clear all cached images
  Future<void> clearAllCache() async {
    // Clear local image cache
    clearLocalImageCache();
    
    // Clear cached network images
    await CachedNetworkImage.evictFromCache('*');
  }
}
