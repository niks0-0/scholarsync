import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Preset avatar options available in ScholarSync.
abstract final class AvatarPresets {
  static const String male = 'assets/avatars/avatar_male.png';
  static const String female = 'assets/avatars/avatar_female.png';
  static const String blank = ''; // Blank / default initial logo
}

/// Unified Avatar Widget for ScholarSync supporting Assets, Remote URLs, Memory Bytes, and Initials.
class StudentAvatar extends StatelessWidget {
  const StudentAvatar({
    super.key,
    this.avatarUrl,
    this.imageBytes,
    this.name,
    this.radius = 24,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
  });

  final String? avatarUrl;
  final Uint8List? imageBytes;
  final String? name;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  ImageProvider? _resolveImageProvider() {
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return MemoryImage(imageBytes!);
    }
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      final url = avatarUrl!.trim();
      if (url.startsWith('assets/')) {
        return AssetImage(url);
      }
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return NetworkImage(url);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final image = _resolveImageProvider();
    final displayName = name?.trim() ?? 'Student';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';

    Widget avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.primary,
                width: borderWidth,
              )
            : null,
        gradient: image == null
            ? LinearGradient(
                colors: isDark
                    ? [
                        AppColors.primary.withValues(alpha: 0.35),
                        AppColors.darkSurfaceVariant,
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.20),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: ClipOval(
        child: image != null
            ? Image(
                image: image,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(isDark, initial),
              )
            : _buildFallback(isDark, initial),
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildFallback(bool isDark, String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
