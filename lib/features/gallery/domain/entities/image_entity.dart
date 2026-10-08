import 'package:equatable/equatable.dart';

class ImageEntity extends Equatable {
  final int id;
  final String pageUrl;
  final String tags;
  final String previewUrl;
  final int previewWidth;
  final int previewHeight;
  final String webformatUrl;
  final int webformatWidth;
  final int webformatHeight;
  final String largeImageUrl;
  final int imageWidth;
  final int imageHeight;
  final int imageSize;
  final int views;
  final int downloads;
  final int collections;
  final int likes;
  final int comments;
  final int userId;
  final String user;
  final String userImageUrl;
  final bool isFavorite;

  const ImageEntity({
    required this.id,
    required this.pageUrl,
    required this.tags,
    required this.previewUrl,
    required this.previewWidth,
    required this.previewHeight,
    required this.webformatUrl,
    required this.webformatWidth,
    required this.webformatHeight,
    required this.largeImageUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageSize,
    required this.views,
    required this.downloads,
    required this.collections,
    required this.likes,
    required this.comments,
    required this.userId,
    required this.user,
    required this.userImageUrl,
    this.isFavorite = false,
  });

  ImageEntity copyWith({
    int? id,
    String? pageUrl,
    String? tags,
    String? previewUrl,
    int? previewWidth,
    int? previewHeight,
    String? webformatUrl,
    int? webformatWidth,
    int? webformatHeight,
    String? largeImageUrl,
    int? imageWidth,
    int? imageHeight,
    int? imageSize,
    int? views,
    int? downloads,
    int? collections,
    int? likes,
    int? comments,
    int? userId,
    String? user,
    String? userImageUrl,
    bool? isFavorite,
  }) {
    return ImageEntity(
      id: id ?? this.id,
      pageUrl: pageUrl ?? this.pageUrl,
      tags: tags ?? this.tags,
      previewUrl: previewUrl ?? this.previewUrl,
      previewWidth: previewWidth ?? this.previewWidth,
      previewHeight: previewHeight ?? this.previewHeight,
      webformatUrl: webformatUrl ?? this.webformatUrl,
      webformatWidth: webformatWidth ?? this.webformatWidth,
      webformatHeight: webformatHeight ?? this.webformatHeight,
      largeImageUrl: largeImageUrl ?? this.largeImageUrl,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      imageSize: imageSize ?? this.imageSize,
      views: views ?? this.views,
      downloads: downloads ?? this.downloads,
      collections: collections ?? this.collections,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Tag list helper
  List<String> get tagList =>
      tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  List<Object?> get props => [
        id,
        pageUrl,
        tags,
        previewUrl,
        webformatUrl,
        largeImageUrl,
        views,
        downloads,
        likes,
        user,
        isFavorite,
      ];
}
