import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../theme/theme_cubit.dart';
import '../utils/download_helper.dart';
import '../../features/gallery/data/datasources/image_local_datasource.dart';
import '../../features/gallery/data/datasources/image_remote_datasource.dart';
import '../../features/gallery/data/repositories/image_repository_impl.dart';
import '../../features/gallery/domain/repositories/image_repository.dart';
import '../../features/gallery/domain/usecases/download_image_usecase.dart';
import '../../features/gallery/domain/usecases/get_favorites_usecase.dart';
import '../../features/gallery/domain/usecases/get_images_usecase.dart';
import '../../features/gallery/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/gallery/presentation/bloc/download/download_cubit.dart';
import '../../features/gallery/presentation/bloc/favorites/favorites_bloc.dart';
import '../../features/gallery/presentation/bloc/gallery/gallery_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  // 1. External & Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<DownloadHelper>(() => DownloadHelper(dio: sl<ApiClient>().dio));

  // 2. Data Sources
  sl.registerLazySingleton<ImageRemoteDataSource>(
    () => ImageRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<ImageLocalDataSource>(
    () => ImageLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // 3. Repositories
  sl.registerLazySingleton<ImageRepository>(
    () => ImageRepositoryImpl(
      remoteDataSource: sl<ImageRemoteDataSource>(),
      localDataSource: sl<ImageLocalDataSource>(),
      downloadHelper: sl<DownloadHelper>(),
    ),
  );

  // 4. Use Cases
  sl.registerLazySingleton(() => GetImagesUseCase(sl<ImageRepository>()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl<ImageRepository>()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl<ImageRepository>()));
  sl.registerLazySingleton(() => DownloadImageUseCase(sl<ImageRepository>()));

  // 5. BLoCs / Cubits
  sl.registerFactory(
    () => GalleryBloc(
      getImagesUseCase: sl<GetImagesUseCase>(),
      toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
    ),
  );

  sl.registerFactory(
    () => FavoritesBloc(
      getFavoritesUseCase: sl<GetFavoritesUseCase>(),
      toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
    ),
  );

  sl.registerFactory(
    () => DownloadCubit(
      downloadImageUseCase: sl<DownloadImageUseCase>(),
    ),
  );

  sl.registerLazySingleton(
    () => ThemeCubit(
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );
}
