import '../../../../core/utils/result.dart';
import '../entities/image_entity.dart';
import '../repositories/image_repository.dart';

class GetFavoritesUseCase {
  final ImageRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<Result<List<ImageEntity>>> call() {
    return repository.getFavorites();
  }
}
