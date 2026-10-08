import '../../../../core/utils/result.dart';
import '../entities/image_entity.dart';
import '../repositories/image_repository.dart';

class ToggleFavoriteUseCase {
  final ImageRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<Result<bool>> call(ImageEntity image) {
    return repository.toggleFavorite(image);
  }
}
