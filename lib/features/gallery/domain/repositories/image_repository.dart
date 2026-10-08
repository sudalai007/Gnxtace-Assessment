import '../../../../core/utils/result.dart';
import '../entities/image_entity.dart';

abstract class ImageRepository {
  Future<Result<List<ImageEntity>>> getImages({
    required int page,
    required int perPage,
    String? query,
    String? category,
  });

  Future<Result<List<ImageEntity>>> getFavorites();

  Future<Result<bool>> toggleFavorite(ImageEntity image);

  Future<Result<bool>> isFavorite(int id);

  Future<Result<String>> downloadImage({
    required String url,
    required String fileName,
    required void Function(int count, int total) onProgress,
  });
}
