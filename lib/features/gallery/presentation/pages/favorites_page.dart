import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../bloc/favorites/favorites_state.dart';
import '../bloc/gallery/gallery_bloc.dart';
import '../bloc/gallery/gallery_event.dart';
import '../widgets/image_grid_item.dart';
import '../widgets/search_bar_widget.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.favorite_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Saved Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Search Bar inside Favorites
          BlocBuilder<FavoritesBloc, FavoritesState>(
            buildWhen: (prev, curr) => prev.query != curr.query,
            builder: (context, state) {
              if (state.favorites.isEmpty) return const SizedBox.shrink();
              return SearchBarWidget(
                initialValue: state.query,
                hintText: 'Search within saved favorites...',
                onChanged: (query) {
                  context.read<FavoritesBloc>().add(SearchFavoritesEvent(query));
                },
                onClear: () {
                  context.read<FavoritesBloc>().add(const SearchFavoritesEvent(''));
                },
              );
            },
          ),

          // Favorites Grid View
          Expanded(
            child: BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                if (state.status == FavoritesStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.favorites.isEmpty) {
                  return _buildEmptyState(context);
                }

                if (state.filteredFavorites.isEmpty) {
                  return const Center(
                    child: Text('No favorite image matching your search.'),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900
                        ? 4
                        : (constraints.maxWidth > 600 ? 3 : 2);

                    return MasonryGridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final image = state.filteredFavorites[index];
                        final height = (index % 3 == 0) ? 250.0 : (index % 2 == 0 ? 190.0 : 220.0);

                        return SizedBox(
                          height: height,
                          child: ImageGridItem(
                            image: image,
                            onTap: () async {
                              await context.push('/detail', extra: image);
                              if (context.mounted) {
                                context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
                              }
                            },
                            onFavoriteToggle: () {
                              context.read<FavoritesBloc>().add(ToggleFavoriteInFavoritesEvent(image));
                              context.read<GalleryBloc>().add(ToggleFavoriteInGallery(image));
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Favorites Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the heart icon on any image in the gallery to save it to your offline favorites list.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Explore Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
