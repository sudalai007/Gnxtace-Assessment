import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/image_entity.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../bloc/favorites/favorites_state.dart';
import '../bloc/gallery/gallery_bloc.dart';
import '../bloc/gallery/gallery_event.dart';
import '../widgets/download_progress_dialog.dart';

class ImageDetailPage extends StatefulWidget {
  final ImageEntity image;

  const ImageDetailPage({super.key, required this.image});

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  late ImageEntity _currentImage;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.image;
  }

  void _shareImage() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'Check out this stunning photo by ${_currentImage.user} on Pixabay: ${_currentImage.largeImageUrl}',
        subject: 'Stunning Image by ${_currentImage.user}',
      ),
    );
  }

  void _downloadImage() {
    final fileName =
        'pixabay_${_currentImage.id}_${DateTime.now().millisecondsSinceEpoch}';
    final url = _currentImage.largeImageUrl.isNotEmpty
        ? _currentImage.largeImageUrl
        : _currentImage.webformatUrl;

    DownloadProgressDialog.show(context, url: url, fileName: fileName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(100),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: _shareImage,
              tooltip: 'Share Image',
            ),
          ),
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              final isFav = state.favorites.any(
                (e) => e.id == _currentImage.id,
              );

              return Container(
                margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.redAccent : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentImage = _currentImage.copyWith(
                        isFavorite: !isFav,
                      );
                    });
                    context.read<FavoritesBloc>().add(
                      ToggleFavoriteInFavoritesEvent(_currentImage),
                    );
                    context.read<GalleryBloc>().add(
                      ToggleFavoriteInGallery(_currentImage),
                    );
                  },
                  tooltip: 'Favorite',
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Full High Res Image Container with Interactive Zoom
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Hero(
                      tag: 'image_hero_${_currentImage.id}',
                      child: CachedNetworkImage(
                        imageUrl: _currentImage.largeImageUrl.isNotEmpty
                            ? _currentImage.largeImageUrl
                            : _currentImage.webformatUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => CachedNetworkImage(
                          imageUrl: _currentImage.webformatUrl,
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            theme.scaffoldBackgroundColor,
                            theme.scaffoldBackgroundColor.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 50 : 15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: theme.colorScheme.primary.withAlpha(
                            40,
                          ),
                          backgroundImage: _currentImage.userImageUrl.isNotEmpty
                              ? NetworkImage(_currentImage.userImageUrl)
                              : null,
                          child: _currentImage.userImageUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentImage.user,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Pixabay Creator • ID: ${_currentImage.userId}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withAlpha(140),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _downloadImage,
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Image Tags Header
                  const Text(
                    'Tags & Keywords',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _currentImage.tagList.map((tag) {
                      return ActionChip(
                        avatar: Icon(
                          Icons.tag,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          tag,
                          style: TextStyle(
                            //  color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        backgroundColor: theme.cardTheme.color,
                        side: BorderSide(
                          color: theme.colorScheme.primary.withAlpha(60),
                        ),
                        onPressed: () {
                          context.read<GalleryBloc>().add(
                            SearchQueryChanged(tag),
                          );
                          context.pop();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Metadata & Statistics Grid
                  const Text(
                    'Image Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    // childAspectRatio: 2.2,
                    children: [
                      _buildStatCard(
                        context,
                        icon: Icons.visibility_rounded,
                        color: Colors.blueAccent,
                        title: 'Views',
                        value: '${_currentImage.views}',
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.favorite_rounded,
                        color: Colors.redAccent,
                        title: 'Likes',
                        value: '${_currentImage.likes}',
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.download_rounded,
                        color: Colors.green,
                        title: 'Downloads',
                        value: '${_currentImage.downloads}',
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.aspect_ratio_rounded,
                        color: Colors.purpleAccent,
                        title: 'Dimensions',
                        value:
                            '${_currentImage.imageWidth} x ${_currentImage.imageHeight}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(130),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
