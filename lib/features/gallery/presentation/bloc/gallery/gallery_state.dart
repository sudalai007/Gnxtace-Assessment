import 'package:equatable/equatable.dart';
import '../../../domain/entities/image_entity.dart';

enum GalleryStatus { initial, loading, success, failure, loadingMore }

class GalleryState extends Equatable {
  final GalleryStatus status;
  final List<ImageEntity> images;
  final int page;
  final bool hasReachedMax;
  final String query;
  final String category;
  final String? errorMessage;
  final bool isMasonry;

  const GalleryState({
    this.status = GalleryStatus.initial,
    this.images = const [],
    this.page = 1,
    this.hasReachedMax = false,
    this.query = '',
    this.category = 'all',
    this.errorMessage,
    this.isMasonry = true,
  });

  GalleryState copyWith({
    GalleryStatus? status,
    List<ImageEntity>? images,
    int? page,
    bool? hasReachedMax,
    String? query,
    String? category,
    String? errorMessage,
    bool? isMasonry,
  }) {
    return GalleryState(
      status: status ?? this.status,
      images: images ?? this.images,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query ?? this.query,
      category: category ?? this.category,
      errorMessage: errorMessage,
      isMasonry: isMasonry ?? this.isMasonry,
    );
  }

  @override
  List<Object?> get props => [
        status,
        images,
        page,
        hasReachedMax,
        query,
        category,
        errorMessage,
        isMasonry,
      ];
}
