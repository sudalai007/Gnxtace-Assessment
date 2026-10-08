import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/image_entity.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../bloc/favorites/favorites_state.dart';
import '../bloc/gallery/gallery_bloc.dart';
import '../bloc/gallery/gallery_event.dart';
import '../bloc/gallery/gallery_state.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/error_display_widget.dart';
import '../widgets/image_grid_item.dart';
import '../widgets/image_shimmer_grid.dart';
import '../widgets/search_bar_widget.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial fetch
    context.read<GalleryBloc>().add(const FetchGalleryImages());
    context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<GalleryBloc>().add(const LoadMoreGalleryImages());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.indigoAccent],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Pixabay Lens',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          // Masonry / Standard Grid Toggle
          BlocBuilder<GalleryBloc, GalleryState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isMasonry ? Icons.dashboard_rounded : Icons.grid_view_rounded,
                  color: theme.colorScheme.primary,
                ),
                tooltip: state.isMasonry ? 'Switch to Grid' : 'Switch to Masonry',
                onPressed: () {
                  context.read<GalleryBloc>().add(const ToggleGridStyle());
                },
              );
            },
          ),
          // Light/Dark Theme Toggle
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amber : Colors.indigo,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          // Favorites Screen Badge Navigation
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              final count = state.favorites.length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                    tooltip: 'Favorites',
                    onPressed: () {
                      context.push('/favorites');
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          BlocBuilder<GalleryBloc, GalleryState>(
            buildWhen: (prev, curr) => prev.query != curr.query,
            builder: (context, state) {
              return SearchBarWidget(
                initialValue: state.query,
                onChanged: (query) {
                  context.read<GalleryBloc>().add(SearchQueryChanged(query));
                },
                onClear: () {
                  context.read<GalleryBloc>().add(const SearchQueryChanged(''));
                },
              );
            },
          ),

          // Category Chips
          BlocBuilder<GalleryBloc, GalleryState>(
            buildWhen: (prev, curr) => prev.category != curr.category,
            builder: (context, state) {
              return CategoryFilterBar(
                selectedCategory: state.category,
                onCategorySelected: (category) {
                  context.read<GalleryBloc>().add(SelectCategory(category));
                },
              );
            },
          ),
          const SizedBox(height: 8),

          // Gallery Grid View Content
          Expanded(
            child: BlocConsumer<GalleryBloc, GalleryState>(
              listener: (context, state) {
                if (state.errorMessage != null && state.images.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == GalleryStatus.loading && state.images.isEmpty) {
                  return ImageShimmerGrid(isMasonry: state.isMasonry);
                }

                if (state.status == GalleryStatus.failure && state.images.isEmpty) {
                  return ErrorDisplayWidget(
                    errorMessage: state.errorMessage ?? 'Failed to load images.',
                    onRetry: () {
                      context.read<GalleryBloc>().add(const FetchGalleryImages());
                    },
                  );
                }

                if (state.images.isEmpty && state.status == GalleryStatus.success) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<GalleryBloc>().add(const RefreshGalleryImages());
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 900
                          ? 4
                          : (constraints.maxWidth > 600 ? 3 : 2);

                      return CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(12),
                            sliver: state.isMasonry
                                ? SliverMasonryGrid.count(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childCount: state.images.length,
                                    itemBuilder: (context, index) {
                                      final image = state.images[index];
                                      return _buildImageItem(context, image, index);
                                    },
                                  )
                                : SliverGrid(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 0.75,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final image = state.images[index];
                                        return _buildImageItem(context, image, index);
                                      },
                                      childCount: state.images.length,
                                    ),
                                  ),
                          ),
                          // Infinite Scroll Loading Spinner at Bottom
                          if (state.status == GalleryStatus.loadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          if (state.hasReachedMax && state.images.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    '🎉 You\'ve reached the end of the gallery!',
                                    style: TextStyle(
                                      color: theme.textTheme.bodyMedium?.color?.withAlpha(120),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(BuildContext context, ImageEntity image, int index) {
    final height = (index % 3 == 0) ? 260.0 : (index % 2 == 0 ? 190.0 : 230.0);

    return SizedBox(
      height: height,
      child: ImageGridItem(
        image: image,
        onTap: () async {
          await context.push('/detail', extra: image);
          // Sync favorites state on returning
          if (context.mounted) {
            context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
            context.read<GalleryBloc>().add(const RefreshGalleryImages());
          }
        },
        onFavoriteToggle: () {
          context.read<GalleryBloc>().add(ToggleFavoriteInGallery(image));
          context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No images found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching for another keyword or category.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<GalleryBloc>().add(const FetchGalleryImages(query: '', category: 'all'));
            },
            child: const Text('Reset Search'),
          ),
        ],
      ),
    );
  }
}
