import 'package:equatable/equatable.dart';
import '../../../domain/entities/image_entity.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {
  const LoadFavoritesEvent();
}

class ToggleFavoriteInFavoritesEvent extends FavoritesEvent {
  final ImageEntity image;

  const ToggleFavoriteInFavoritesEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class SearchFavoritesEvent extends FavoritesEvent {
  final String query;

  const SearchFavoritesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
