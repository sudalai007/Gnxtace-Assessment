import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_images_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GetImagesUseCase getImagesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  GalleryBloc({
    required this.getImagesUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(const GalleryState()) {
    on<FetchGalleryImages>(_onFetchGalleryImages);
    on<LoadMoreGalleryImages>(_onLoadMoreGalleryImages);
    on<RefreshGalleryImages>(_onRefreshGalleryImages);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SelectCategory>(_onSelectCategory);
    on<ToggleFavoriteInGallery>(_onToggleFavoriteInGallery);
    on<ToggleGridStyle>(_onToggleGridStyle);
  }

  Future<void> _onFetchGalleryImages(
    FetchGalleryImages event,
    Emitter<GalleryState> emit,
  ) async {
    final query = event.query ?? state.query;
    final category = event.category ?? state.category;

    emit(state.copyWith(
      status: GalleryStatus.loading,
      query: query,
      category: category,
      page: 1,
      hasReachedMax: false,
    ));

    final result = await getImagesUseCase(
      GetImagesParams(
        page: 1,
        query: query,
        category: category,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: GalleryStatus.failure,
        errorMessage: failure.message,
      )),
      (images) => emit(state.copyWith(
        status: GalleryStatus.success,
        images: images,
        page: 1,
        hasReachedMax: images.isEmpty || images.length < 20,
      )),
    );
  }

  Future<void> _onLoadMoreGalleryImages(
    LoadMoreGalleryImages event,
    Emitter<GalleryState> emit,
  ) async {
    if (state.hasReachedMax || state.status == GalleryStatus.loadingMore || state.status == GalleryStatus.loading) {
      return;
    }

    final nextPage = state.page + 1;
    emit(state.copyWith(status: GalleryStatus.loadingMore));

    final result = await getImagesUseCase(
      GetImagesParams(
        page: nextPage,
        query: state.query,
        category: state.category,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: GalleryStatus.success, // Keep existing images on load more fail
        errorMessage: failure.message,
      )),
      (newImages) {
        if (newImages.isEmpty) {
          emit(state.copyWith(
            status: GalleryStatus.success,
            hasReachedMax: true,
          ));
        } else {
          final updatedList = List.of(state.images)..addAll(newImages);
          emit(state.copyWith(
            status: GalleryStatus.success,
            images: updatedList,
            page: nextPage,
            hasReachedMax: newImages.length < 20,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshGalleryImages(
    RefreshGalleryImages event,
    Emitter<GalleryState> emit,
  ) async {
    final result = await getImagesUseCase(
      GetImagesParams(
        page: 1,
        query: state.query,
        category: state.category,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (images) => emit(state.copyWith(
        status: GalleryStatus.success,
        images: images,
        page: 1,
        hasReachedMax: images.length < 20,
      )),
    );
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<GalleryState> emit,
  ) {
    add(FetchGalleryImages(query: event.query, category: state.category));
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<GalleryState> emit,
  ) {
    add(FetchGalleryImages(query: state.query, category: event.category));
  }

  Future<void> _onToggleFavoriteInGallery(
    ToggleFavoriteInGallery event,
    Emitter<GalleryState> emit,
  ) async {
    final updatedImage = event.image.copyWith(isFavorite: !event.image.isFavorite);

    // Optimistic UI update
    final updatedImages = state.images.map((img) {
      return img.id == event.image.id ? updatedImage : img;
    }).toList();

    emit(state.copyWith(images: updatedImages));

    final result = await toggleFavoriteUseCase(event.image);
    result.fold(
      (failure) {
        // Rollback on failure
        final rollbackImages = state.images.map((img) {
          return img.id == event.image.id ? event.image : img;
        }).toList();
        emit(state.copyWith(images: rollbackImages, errorMessage: failure.message));
      },
      (_) {},
    );
  }

  void _onToggleGridStyle(
    ToggleGridStyle event,
    Emitter<GalleryState> emit,
  ) {
    emit(state.copyWith(isMasonry: !state.isMasonry));
  }
}
