import 'package:equatable/equatable.dart';
import '../../../domain/entities/image_entity.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<ImageEntity> favorites;
  final List<ImageEntity> filteredFavorites;
  final String query;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.filteredFavorites = const [],
    this.query = '',
    this.errorMessage,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<ImageEntity>? favorites,
    List<ImageEntity>? filteredFavorites,
    String? query,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        favorites,
        filteredFavorites,
        query,
        errorMessage,
      ];
}
