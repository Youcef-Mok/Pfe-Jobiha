// lib/core/utils/media_utils.dart

/// Utility functions for handling media URLs from Django backend
class MediaUtils {
  // Base URL for your Django backend
  // TODO: Change this to your production URL when deploying
  static const String _baseUrl = 'http://localhost:8000';
  
  /// Converts a relative media path to a full URL
  /// 
  /// Examples:
  /// - '/media/avatars/user_7.jpg' -> 'http://localhost:8000/media/avatars/user_7.jpg'
  /// - 'media/logos/demo_company.png' -> 'http://localhost:8000/media/logos/demo_company.png'
  /// - 'http://example.com/image.jpg' -> 'http://example.com/image.jpg' (unchanged)
  /// - null -> null
  static String? getMediaUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    
    // If already a full URL, return as-is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // If starts with /media/, append to base URL
    if (path.startsWith('/media/')) {
      return '$_baseUrl$path';
    }
    
    // If starts with media/ (without leading slash), add slash and append
    if (path.startsWith('media/')) {
      return '$_baseUrl/$path';
    }
    
    // For any other relative path, assume it's a media path
    return '$_baseUrl/media/$path';
  }
  
  /// Gets avatar URL with fallback to default avatar
  static String getAvatarUrl(String? avatarPath) {
    final url = getMediaUrl(avatarPath);
    // If no avatar, return a default placeholder
    // You can replace this with your own default avatar asset
    return url ?? 'assets/images/default_avatar.png';
  }
  
  /// Gets logo URL with fallback to default logo
  static String getLogoUrl(String? logoPath) {
    final url = getMediaUrl(logoPath);
    return url ?? 'assets/images/default_logo.png';
  }
  
  /// Gets job image URL with fallback to default job image
  static String getJobImageUrl(String? imagePath) {
    final url = getMediaUrl(imagePath);
    return url ?? 'assets/images/default_job.png';
  }
  
  /// Gets mission image URL with fallback to default mission image
  static String getMissionImageUrl(String? imagePath) {
    final url = getMediaUrl(imagePath);
    return url ?? 'assets/images/default_mission.png';
  }
  
  /// Checks if a path is a network URL (not a local asset)
  static bool isNetworkUrl(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.startsWith('http://') || 
           path.startsWith('https://') || 
           path.startsWith('/media/') ||
           path.startsWith('media/');
  }
}
