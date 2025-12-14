import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Avatar Manager for handling user profile pictures
/// Supports both asset images and emoji fallbacks
class AvatarManager {
  /// Get avatar widget for display
  static Widget getAvatarWidget(
    int? avatarIndex, {
    double size = 50,
    bool showBorder = true,
    Color? borderColor,
    double borderWidth = 2,
  }) {
    final effectiveIndex = avatarIndex ?? 0;
    final isImageAvatar = effectiveIndex < AppConstants.avatarImages.length;
    
    Widget avatarChild;
    
    if (isImageAvatar) {
      // Use asset image
      avatarChild = ClipOval(
        child: Image.asset(
          AppConstants.avatarImages[effectiveIndex],
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to emoji if image fails to load
            return _buildEmojiAvatar(effectiveIndex, size);
          },
        ),
      );
    } else {
      // Use emoji fallback
      avatarChild = _buildEmojiAvatar(effectiveIndex, size);
    }

    if (showBorder) {
      return Container(
        width: size + borderWidth * 2,
        height: size + borderWidth * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.3),
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: avatarChild,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: avatarChild,
    );
  }

  /// Build emoji avatar fallback
  static Widget _buildEmojiAvatar(int index, double size) {
    final emoji = AppConstants.avatarEmojis[index % AppConstants.avatarEmojis.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getGradientColorForIndex(index).withOpacity(0.8),
            _getGradientColorForIndex(index),
          ],
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: size * 0.4,
            fontFamily: 'NotoColorEmoji',
          ),
        ),
      ),
    );
  }

  /// Get gradient color based on avatar index
  static Color _getGradientColorForIndex(int index) {
    const colors = [
      Color(0xFF7C3AED), // Purple
      Color(0xFF3B82F6), // Blue  
      Color(0xFF10B981), // Emerald
      Color(0xFFF59E0B), // Amber
      Color(0xFFEF4444), // Red
      Color(0xFF8B5CF6), // Violet
      Color(0xFF06B6D4), // Cyan
      Color(0xFF84CC16), // Lime
      Color(0xFFF97316), // Orange
    ];
    return colors[index % colors.length];
  }

  /// Get total number of available avatars
  static int get totalAvatarCount => 
      AppConstants.avatarImages.length + AppConstants.avatarEmojis.length;

  /// Check if avatar index corresponds to an image
  static bool isImageAvatar(int index) => 
      index < AppConstants.avatarImages.length;

  /// Get avatar path or emoji string
  static String getAvatarSource(int index) {
    if (isImageAvatar(index)) {
      return AppConstants.avatarImages[index];
    } else {
      final emojiIndex = index - AppConstants.avatarImages.length;
      return AppConstants.avatarEmojis[emojiIndex % AppConstants.avatarEmojis.length];
    }
  }

  /// Avatar selection grid widget
  static Widget buildAvatarSelectionGrid({
    required int selectedIndex,
    required Function(int) onAvatarSelected,
    double avatarSize = 50,
    int crossAxisCount = 4,
    double spacing = 12,
  }) {
    final totalAvatars = totalAvatarCount;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: totalAvatars,
      itemBuilder: (context, index) {
        final isSelected = index == selectedIndex;
        
        return GestureDetector(
          onTap: () => onAvatarSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF7C3AED)
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ] : [],
            ),
            child: getAvatarWidget(
              index,
              size: avatarSize,
              showBorder: false,
            ),
          ),
        );
      },
    );
  }

  /// Avatar section titles for grouped display
  static List<String> get sectionTitles => ['Custom Avatars', 'Emoji Avatars'];

  /// Get avatars by section
  static List<int> getAvatarsBySection(int sectionIndex) {
    switch (sectionIndex) {
      case 0: // Custom Avatars
        return List.generate(AppConstants.avatarImages.length, (i) => i);
      case 1: // Emoji Avatars  
        return List.generate(
          AppConstants.avatarEmojis.length, 
          (i) => AppConstants.avatarImages.length + i,
        );
      default:
        return [];
    }
  }

  /// Build sectioned avatar selection
  static Widget buildSectionedAvatarSelection({
    required int selectedIndex,
    required Function(int) onAvatarSelected,
    double avatarSize = 50,
    int crossAxisCount = 4,
    double spacing = 12,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom Avatars Section
        if (AppConstants.avatarImages.isNotEmpty) ...[
          const Text(
            'Custom Avatars',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
            ),
            itemCount: AppConstants.avatarImages.length,
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;
              
              return GestureDetector(
                onTap: () => onAvatarSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF7C3AED)
                          : Colors.white.withOpacity(0.2),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ] : [],
                  ),
                  child: getAvatarWidget(
                    index,
                    size: avatarSize,
                    showBorder: false,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
        
        // Emoji Avatars Section
        const Text(
          'Emoji Avatars',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
          ),
          itemCount: AppConstants.avatarEmojis.length,
          itemBuilder: (context, index) {
            final avatarIndex = AppConstants.avatarImages.length + index;
            final isSelected = avatarIndex == selectedIndex;
            
            return GestureDetector(
              onTap: () => onAvatarSelected(avatarIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF7C3AED)
                        : Colors.white.withOpacity(0.2),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ] : [],
                ),
                child: getAvatarWidget(
                  avatarIndex,
                  size: avatarSize,
                  showBorder: false,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Avatar data model for convenience
class AvatarData {
  final int index;
  final String source;
  final bool isImage;

  AvatarData({
    required this.index,
    required this.source,
    required this.isImage,
  });

  static AvatarData fromIndex(int index) {
    return AvatarData(
      index: index,
      source: AvatarManager.getAvatarSource(index),
      isImage: AvatarManager.isImageAvatar(index),
    );
  }
}