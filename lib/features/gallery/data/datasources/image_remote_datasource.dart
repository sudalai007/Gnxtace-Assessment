import '../../../../core/api/api_client.dart';
import '../models/image_model.dart';

abstract class ImageRemoteDataSource {
  Future<List<ImageModel>> getImages({
    required int page,
    required int perPage,
    String? query,
    String? category,
  });
}

class ImageRemoteDataSourceImpl implements ImageRemoteDataSource {
  final ApiClient apiClient;

  ImageRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ImageModel>> getImages({
    required int page,
    required int perPage,
    String? query,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = Uri.encodeComponent(query.trim());
    }

    if (category != null && category.trim().isNotEmpty && category.toLowerCase() != 'all') {
      queryParams['category'] = category.toLowerCase().trim();
    }

    final response = await apiClient.get('', queryParameters: queryParams);

    final List<dynamic> hits = response['hits'] as List<dynamic>? ?? [];
    return hits.map((json) => ImageModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
