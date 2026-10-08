import 'package:equatable/equatable.dart';
import '../../../domain/entities/image_entity.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object?> get props => [];
}

class FetchGalleryImages extends GalleryEvent {
  final String? query;
  final String? category;

  const FetchGalleryImages({this.query, this.category});

  @override
  List<Object?> get props => [query, category];
}

class LoadMoreGalleryImages extends GalleryEvent {
  const LoadMoreGalleryImages();
}

class RefreshGalleryImages extends GalleryEvent {
  const RefreshGalleryImages();
}

class SearchQueryChanged extends GalleryEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectCategory extends GalleryEvent {
  final String category;

  const SelectCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class ToggleFavoriteInGallery extends GalleryEvent {
  final ImageEntity image;

  const ToggleFavoriteInGallery(this.image);

  @override
  List<Object?> get props => [image];
}

class ToggleGridStyle extends GalleryEvent {
  const ToggleGridStyle();
}
