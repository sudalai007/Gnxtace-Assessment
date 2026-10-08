import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gnxtace_assessment/core/utils/result.dart';
import 'package:gnxtace_assessment/features/gallery/domain/entities/image_entity.dart';
import 'package:gnxtace_assessment/features/gallery/domain/usecases/get_images_usecase.dart';
import 'package:gnxtace_assessment/features/gallery/domain/usecases/toggle_favorite_usecase.dart';
import 'package:gnxtace_assessment/features/gallery/presentation/bloc/gallery/gallery_bloc.dart';
import 'package:gnxtace_assessment/features/gallery/presentation/bloc/gallery/gallery_event.dart';
import 'package:gnxtace_assessment/features/gallery/presentation/bloc/gallery/gallery_state.dart';

class MockGetImagesUseCase extends Mock implements GetImagesUseCase {}
class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}

void main() {
  late GalleryBloc galleryBloc;
  late MockGetImagesUseCase mockGetImagesUseCase;
  late MockToggleFavoriteUseCase mockToggleFavoriteUseCase;

  setUp(() {
    mockGetImagesUseCase = MockGetImagesUseCase();
    mockToggleFavoriteUseCase = MockToggleFavoriteUseCase();
    galleryBloc = GalleryBloc(
      getImagesUseCase: mockGetImagesUseCase,
      toggleFavoriteUseCase: mockToggleFavoriteUseCase,
    );
    registerFallbackValue(const GetImagesParams(page: 1));
  });

  tearDown(() {
    galleryBloc.close();
  });

  const tImage = ImageEntity(
    id: 10,
    pageUrl: '',
    tags: 'sky',
    previewUrl: '',
    previewWidth: 100,
    previewHeight: 100,
    webformatUrl: '',
    webformatWidth: 640,
    webformatHeight: 480,
    largeImageUrl: '',
    imageWidth: 1000,
    imageHeight: 1000,
    imageSize: 500,
    views: 10,
    downloads: 5,
    collections: 1,
    likes: 2,
    comments: 0,
    userId: 1,
    user: 'Artist',
    userImageUrl: '',
  );

  test('initial state should be GalleryState()', () {
    expect(galleryBloc.state, equals(const GalleryState()));
  });

  blocTest<GalleryBloc, GalleryState>(
    'emits [GalleryStatus.loading, GalleryStatus.success] when FetchGalleryImages succeeds',
    build: () {
      when(() => mockGetImagesUseCase(any())).thenAnswer((_) async => const Success([tImage]));
      return galleryBloc;
    },
    act: (bloc) => bloc.add(const FetchGalleryImages()),
    expect: () => [
      const GalleryState(status: GalleryStatus.loading, page: 1),
      const GalleryState(
        status: GalleryStatus.success,
        images: [tImage],
        page: 1,
        hasReachedMax: true, // < 20 items returned
      ),
    ],
  );
}
