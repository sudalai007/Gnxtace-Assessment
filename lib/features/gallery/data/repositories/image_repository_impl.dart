import '../../../../core/api/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/download_helper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/repositories/image_repository.dart';
import '../datasources/image_local_datasource.dart';
import '../datasources/image_remote_datasource.dart';
import '../models/image_model.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageRemoteDataSource remoteDataSource;
  final ImageLocalDataSource localDataSource;
  final DownloadHelper downloadHelper;

  ImageRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.downloadHelper,
  });

  @override
  Future<Result<List<ImageEntity>>> getImages({
    required int page,
    required int perPage,
    String? query,
    String? category,
  }) async {
    try {
      final remoteModels = await remoteDataSource.getImages(
        page: page,
        perPage: perPage,
        query: query,
        category: category,
      );

      final favoriteIds = await localDataSource.getFavoriteIds();

      final entities = remoteModels.map((model) {
        final isFav = favoriteIds.contains(model.id);
        return model.copyWithModel(isFavorite: isFav);
      }).toList();

      return Success(entities);
    } on ApiException catch (e) {
      if (e is NetworkException) {
        return const FailureResult(NetworkFailure());
      } else if (e is ServerException || e is RateLimitException) {
        return FailureResult(ServerFailure(e.message));
      } else {
        return FailureResult(UnknownFailure(e.message));
      }
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ImageEntity>>> getFavorites() async {
    try {
      final models = await localDataSource.getFavorites();
      return Success(models);
    } catch (e) {
      return const FailureResult(CacheFailure('Could not fetch stored favorites.'));
    }
  }

  @override
  Future<Result<bool>> toggleFavorite(ImageEntity image) async {
    try {
      final model = ImageModel.fromEntity(image);
      final isFav = await localDataSource.isFavorite(image.id);

      if (isFav) {
        await localDataSource.removeFavorite(image.id);
        return const Success(false);
      } else {
        await localDataSource.saveFavorite(model);
        return const Success(true);
      }
    } catch (e) {
      return const FailureResult(CacheFailure('Failed to update favorite status.'));
    }
  }

  @override
  Future<Result<bool>> isFavorite(int id) async {
    try {
      final isFav = await localDataSource.isFavorite(id);
      return Success(isFav);
    } catch (e) {
      return const FailureResult(CacheFailure());
    }
  }

  @override
  Future<Result<String>> downloadImage({
    required String url,
    required String fileName,
    required void Function(int count, int total) onProgress,
  }) async {
    try {
      final filePath = await downloadHelper.downloadImage(
        url: url,
        fileName: fileName,
        onProgress: onProgress,
      );
      return Success(filePath);
    } catch (e) {
      return FailureResult(StorageFailure(e.toString()));
    }
  }
}
