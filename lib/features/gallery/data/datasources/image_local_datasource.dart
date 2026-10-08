import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/image_model.dart';

abstract class ImageLocalDataSource {
  Future<List<ImageModel>> getFavorites();
  Future<bool> saveFavorite(ImageModel image);
  Future<bool> removeFavorite(int id);
  Future<bool> isFavorite(int id);
  Future<Set<int>> getFavoriteIds();
}

class ImageLocalDataSourceImpl implements ImageLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _favoritesKey = 'user_favorite_images';

  ImageLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ImageModel>> getFavorites() async {
    final jsonList = sharedPreferences.getStringList(_favoritesKey) ?? [];
    return jsonList
        .map((str) => ImageModel.fromJson(json.decode(str) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Set<int>> getFavoriteIds() async {
    final favorites = await getFavorites();
    return favorites.map((e) => e.id).toSet();
  }

  @override
  Future<bool> saveFavorite(ImageModel image) async {
    final favorites = await getFavorites();
    // Avoid duplicate entry
    favorites.removeWhere((item) => item.id == image.id);
    favorites.insert(0, image.copyWithModel(isFavorite: true));

    final jsonList = favorites.map((item) => json.encode(item.toJson())).toList();
    return await sharedPreferences.setStringList(_favoritesKey, jsonList);
  }

  @override
  Future<bool> removeFavorite(int id) async {
    final favorites = await getFavorites();
    favorites.removeWhere((item) => item.id == id);

    final jsonList = favorites.map((item) => json.encode(item.toJson())).toList();
    return await sharedPreferences.setStringList(_favoritesKey, jsonList);
  }

  @override
  Future<bool> isFavorite(int id) async {
    final ids = await getFavoriteIds();
    return ids.contains(id);
  }
}
