# 📸 Pixabay Lens - Production Infinite Image Gallery App (Flutter)

A modern, production-grade Flutter application built with **Clean Architecture**, **flutter_bloc**, **go_router**, **Dio**, **GetIt**, and **SharedPreferences**.

---

## 🌟 Key Features & Highlights

- **Clean Architecture & Separation of Concerns**: Strict division into `Data`, `Domain`, and `Presentation` layers.
- **State Management with BLoC**: Powered by `flutter_bloc` (`GalleryBloc`, `FavoritesBloc`, `DownloadCubit`, `ThemeCubit`).
- **Infinite Scroll & Pagination**: Smooth paginated API fetching via `ScrollController` listener.
- **Masonry & Standard Grid Switcher**: Interactive layout toggle using `flutter_staggered_grid_view`.
- **Search with Debounce**: Real-time debounced search bar with instant query feedback.
- **Category Filter Chips**: Scrollable filter bar featuring Pixabay categories (`nature`, `science`, `education`, `travel`, etc.).
- **Pull-To-Refresh**: Built-in `RefreshIndicator` support.
- **High-Resolution Detail View**: Fullscreen image preview with pinch-to-zoom (`InteractiveViewer`), author details, and keyword tag chips.
- **Image Performance & Caching**: Powered by `cached_network_image` with shimmer loading skeletons (`shimmer`).
- **Local Persistence & Favorites**: Bookmark images locally for offline access using `SharedPreferences`.
- **Image Downloading with Visual Progress**: Real-time progress bar dialog downloading high-res images to device storage via `Dio`.
- **Image Sharing**: Native image link & attribution sharing powered by `share_plus`.
- **Dynamic Light & Dark Theme**: Custom dark background palette with glassmorphism touches and persistent theme preference.
- **Automated Testing Suite**: Unit tests (`bloc_test`, `mocktail`) and Widget tests.

---

## 🏛️ Clean Architecture Breakdown

```
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart          # Dio client with interceptors & error handlers
│   │   ├── api_constants.dart       # Pixabay API endpoints & key configuration
│   │   └── api_exception.dart       # Typed exception hierarchy (Network, Server, RateLimit)
│   ├── errors/
│   │   └── failures.dart            # Domain failure objects
│   ├── injection/
│   │   └── injection_container.dart # GetIt dependency injection locator
│   ├── router/
│   │   └── app_router.dart          # GoRouter navigation configuration & route transitions
│   ├── theme/
│   │   ├── app_theme.dart           # Custom Material 3 Light & Dark themes
│   │   └── theme_cubit.dart         # Theme mode state management & persistence
│   └── utils/
│       ├── download_helper.dart     # Downloader with progress stream callbacks
│       └── result.dart              # Functional Result<T> pattern (Success / FailureResult)
│
└── features/
    └── gallery/
        ├── data/
        │   ├── datasources/
        │   │   ├── image_remote_datasource.dart # Dio HTTP remote requests
        │   │   └── image_local_datasource.dart  # SharedPreferences local favorites JSON storage
        │   ├── models/
        │   │   └── image_model.dart            # JSON DTO mapping to/from Domain Entity
        │   └── repositories/
        │       └── image_repository_impl.dart   # Implementation bridging remote & local data
        ├── domain/
        │   ├── entities/
        │   │   └── image_entity.dart           # Core Dart Domain Entity
        │   ├── repositories/
        │   │   └── image_repository.dart        # Abstract Domain Contract
        │   └── usecases/
        │       ├── get_images_usecase.dart      # Paginated image fetch use case
        │       ├── toggle_favorite_usecase.dart # Add/Remove favorite use case
        │       ├── get_favorites_usecase.dart   # Fetch stored favorites use case
        │       └── download_image_usecase.dart  # Download file use case
        └── presentation/
            ├── bloc/
            │   ├── gallery/                     # GalleryBloc, GalleryEvent, GalleryState
            │   ├── favorites/                   # FavoritesBloc, FavoritesEvent, FavoritesState
            │   └── download/                    # DownloadCubit, DownloadState
            ├── pages/
            │   ├── gallery_page.dart            # Main Home infinite grid screen
            │   ├── image_detail_page.dart       # Fullscreen detail & metadata view
            │   └── favorites_page.dart          # Offline favorites management screen
            └── widgets/
                ├── image_grid_item.dart         # Masonry tile with Hero transition
                ├── category_filter_bar.dart     # Category selector chips
                ├── search_bar_widget.dart       # Debounced search bar
                ├── image_shimmer_grid.dart      # Skeletal loading placeholder
                ├── download_progress_dialog.dart# Download progress bar dialog
                └── error_display_widget.dart    # Error state card with Retry button
```

---

## 🔑 API Key Configuration

The app consumes the **Pixabay API**.

### Setting Up Your API Key:

1. Obtain a free API key by registering at [Pixabay API](https://pixabay.com/api/docs/).
2. Open [`lib/core/api/api_constants.dart`](file:///f:/Workout%20Projects/gnxtace_assessment/lib/core/api/api_constants.dart):

```dart
class ApiConstants {
  static const String baseUrl = 'https://pixabay.com/api/';
  
  // Replace with your Pixabay API Key:
  static String apiKey = 'YOUR_PIXABAY_API_KEY_HERE';
}
```

---

## 🚀 How to Run the Project

### Prerequisites:
- Flutter SDK `^3.35.0`
- Dart SDK `^3.9.0`

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Run Static Analysis & Tests
```bash
flutter analyze
flutter test
```

### Step 3: Launch Application
```bash
# Run on connected device / emulator
flutter run

# Or run specific target platform (Chrome, Windows, Android, iOS):
flutter run -d chrome
flutter run -d windows
```

---

## 🧪 Testing Coverage

The codebase includes both **Unit Tests** and **Widget Tests**:

- **`test/unit/get_images_usecase_test.dart`**: Verifies domain logic and repository interactions using `mocktail`.
- **`test/unit/gallery_bloc_test.dart`**: Tests `GalleryBloc` state emissions (`loading`, `success`, `failure`) using `bloc_test`.
- **`test/widget/widgets_test.dart`**: Tests widget rendering and interactions for `CategoryFilterBar` and `SearchBarWidget`.

Execute tests:
```bash
flutter test
```

---

## 📝 Assumptions & Limitations

1. **Pixabay API Constraints**: Pixabay returns 20 items per page by default. Searching with empty query returns popular images.
2. **Offline Mode**: Favorites saved locally via `SharedPreferences` are viewable offline. Images fetched online rely on HTTP caching.
3. **Storage Permissions**: Downloading images on Android requires storage permissions; on Desktop/Windows files save to the user's document directory.
