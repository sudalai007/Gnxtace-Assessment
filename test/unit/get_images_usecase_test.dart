import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gnxtace_assessment/core/utils/result.dart';
import 'package:gnxtace_assessment/features/gallery/domain/entities/image_entity.dart';
import 'package:gnxtace_assessment/features/gallery/domain/repositories/image_repository.dart';
import 'package:gnxtace_assessment/features/gallery/domain/usecases/get_images_usecase.dart';

class MockImageRepository extends Mock implements ImageRepository {}

void main() {
  late GetImagesUseCase useCase;
  late MockImageRepository mockRepository;

  setUp(() {
    mockRepository = MockImageRepository();
    useCase = GetImagesUseCase(mockRepository);
  });

  const tImage = ImageEntity(
    id: 1,
    pageUrl: 'https://pixabay.com/photos/nature-1',
    tags: 'nature, forest',
    previewUrl: 'https://example.com/preview.jpg',
    previewWidth: 150,
    previewHeight: 150,
    webformatUrl: 'https://example.com/web.jpg',
    webformatWidth: 640,
    webformatHeight: 480,
    largeImageUrl: 'https://example.com/large.jpg',
    imageWidth: 1920,
    imageHeight: 1080,
    imageSize: 1024,
    views: 100,
    downloads: 50,
    collections: 5,
    likes: 25,
    comments: 2,
    userId: 99,
    user: 'TestUser',
    userImageUrl: '',
    isFavorite: false,
  );

  test('should call repository.getImages and return Success with image list', () async {
    // Arrange
    when(() => mockRepository.getImages(
          page: 1,
          perPage: 20,
          query: 'nature',
          category: 'all',
        )).thenAnswer((_) async => const Success([tImage]));

    // Act
    final result = await useCase(const GetImagesParams(
      page: 1,
      perPage: 20,
      query: 'nature',
      category: 'all',
    ));

    // Assert
    expect(result.isSuccess, true);
    expect(result.data, equals([tImage]));
    verify(() => mockRepository.getImages(
          page: 1,
          perPage: 20,
          query: 'nature',
          category: 'all',
        )).called(1);
  });
}
