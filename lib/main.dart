import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/injection/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/gallery/presentation/bloc/download/download_cubit.dart';
import 'features/gallery/presentation/bloc/favorites/favorites_bloc.dart';
import 'features/gallery/presentation/bloc/gallery/gallery_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Clean Architecture Dependency Injection Locator
  await initDependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
        ),
        BlocProvider<GalleryBloc>(
          create: (_) => sl<GalleryBloc>(),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) => sl<FavoritesBloc>(),
        ),
        BlocProvider<DownloadCubit>(
          create: (_) => sl<DownloadCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Pixabay Lens - Infinite Gallery',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
