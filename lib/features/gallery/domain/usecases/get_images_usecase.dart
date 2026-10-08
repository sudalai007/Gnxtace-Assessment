import '../../../../core/utils/result.dart';
import '../entities/image_entity.dart';
import '../repositories/image_repository.dart';

class GetImagesParams {
  final int page;
  final int perPage;
  final String? query;
  final String? category;

  const GetImagesParams({
    required this.page,
    this.perPage = 20,
    this.query,
    this.category,
  });
}

class GetImagesUseCase {
  final ImageRepository repository;

  GetImagesUseCase(this.repository);

  Future<Result<List<ImageEntity>>> call(GetImagesParams params) {
    return repository.getImages(
      page: params.page,
      perPage: params.perPage,
      query: params.query,
      category: params.category,
    );
  }
}
