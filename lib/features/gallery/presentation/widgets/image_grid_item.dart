import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/image_entity.dart';

class ImageGridItem extends StatelessWidget {
  final ImageEntity image;
  final VoidTapCallback onTap;
  final VoidTapCallback onFavoriteToggle;

  const ImageGridItem({
    super.key,
    required this.image,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 80 : 30),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hero Cached Image
              Hero(
                tag: 'image_hero_${image.id}',
                child: CachedNetworkImage(
                  imageUrl: image.webformatUrl.isNotEmpty
                      ? image.webformatUrl
                      : image.previewUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                    child: Container(color: isDark ? Colors.grey[900] : Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),

              // Gradient Overlay at Bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withAlpha(200),
                        Colors.black.withAlpha(100),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // User Avatar or Icon
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white24,
                        backgroundImage: image.userImageUrl.isNotEmpty
                            ? NetworkImage(image.userImageUrl)
                            : null,
                        child: image.userImageUrl.isEmpty
                            ? const Icon(Icons.person, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      // Username & Likes
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              image.user,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.favorite, size: 10, color: Colors.redAccent),
                                const SizedBox(width: 3),
                                Text(
                                  '${image.likes}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Right Favorite Button
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withAlpha(110),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onFavoriteToggle,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        image.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: image.isFavorite ? Colors.redAccent : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef VoidTapCallback = void Function();
