import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/image_entity.dart';
import '../../../domain/usecases/get_favorites_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(const FavoritesState()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteInFavoritesEvent>(_onToggleFavoriteInFavorites);
    on<SearchFavoritesEvent>(_onSearchFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    final result = await getFavoritesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: failure.message,
      )),
      (list) {
        final filtered = _applyFilter(list, state.query);
        emit(state.copyWith(
          status: FavoritesStatus.success,
          favorites: list,
          filteredFavorites: filtered,
        ));
      },
    );
  }

  Future<void> _onToggleFavoriteInFavorites(
    ToggleFavoriteInFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await toggleFavoriteUseCase(event.image);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => add(const LoadFavoritesEvent()),
    );
  }

  void _onSearchFavorites(
    SearchFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) {
    final filtered = _applyFilter(state.favorites, event.query);
    emit(state.copyWith(
      query: event.query,
      filteredFavorites: filtered,
    ));
  }

  List<ImageEntity> _applyFilter(List<ImageEntity> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    return list.where((item) {
      return item.tags.toLowerCase().contains(q) ||
          item.user.toLowerCase().contains(q);
    }).toList();
  }
}
