// lib/core/widgets/smart_image.dart

import 'package:flutter/material.dart';
import '../utils/media_utils.dart';

/// A smart image widget that automatically handles:
/// - Network images from Django backend (/media/...)
/// - Local asset images (assets/...)
/// - Fallback to placeholder on error
class SmartImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? fallbackAsset;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // If no image URL provided, show fallback or error widget
    if (imageUrl == null || imageUrl!.isEmpty) {
      if (fallbackAsset != null) {
        return Image.asset(
          fallbackAsset!,
          width: width,
          height: height,
          fit: fit,
        );
      }
      return errorWidget ?? _defaultErrorWidget();
    }

    // Check if it's a network URL (from Django backend)
    if (MediaUtils.isNetworkUrl(imageUrl)) {
      final fullUrl = MediaUtils.getMediaUrl(imageUrl);
      return Image.network(
        fullUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _defaultPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          // On error, try fallback asset if provided
          if (fallbackAsset != null) {
            return Image.asset(
              fallbackAsset!,
              width: width,
              height: height,
              fit: fit,
            );
          }
          return errorWidget ?? _defaultErrorWidget();
        },
      );
    }

    // Otherwise, treat as local asset
    return Image.asset(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (fallbackAsset != null) {
          return Image.asset(
            fallbackAsset!,
            width: width,
            height: height,
            fit: fit,
          );
        }
        return errorWidget ?? _defaultErrorWidget();
      },
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.broken_image,
        size: (width != null && height != null) ? (width! + height!) / 4 : 40,
        color: Colors.grey[600],
      ),
    );
  }
}

/// Smart avatar widget with circular shape
class SmartAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackAsset;

  const SmartAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: ClipOval(
        child: SmartImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          fallbackAsset: fallbackAsset ?? 'assets/images/default_avatar.png',
        ),
      ),
    );
  }
}

/// Smart logo widget with rounded corners
class SmartLogo extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;
  final String? fallbackAsset;
  final String? fallbackText;

  const SmartLogo({
    super.key,
    required this.imageUrl,
    this.size = 50,
    this.borderRadius = 8,
    this.fallbackAsset,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SmartImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fallbackAsset: fallbackAsset,
        errorWidget: _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFE1DDEC), // AppColors.violetLight
      alignment: Alignment.center,
      child: Text(
        fallbackText != null && fallbackText!.isNotEmpty 
            ? fallbackText![0].toUpperCase()
            : '?',
        style: TextStyle(
          color: const Color(0xFF401E66), // AppColors.violet
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
