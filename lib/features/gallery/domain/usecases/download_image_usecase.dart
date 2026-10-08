import '../../../../core/utils/result.dart';
import '../repositories/image_repository.dart';

class DownloadImageParams {
  final String url;
  final String fileName;
  final void Function(int count, int total) onProgress;

  const DownloadImageParams({
    required this.url,
    required this.fileName,
    required this.onProgress,
  });
}

class DownloadImageUseCase {
  final ImageRepository repository;

  DownloadImageUseCase(this.repository);

  Future<Result<String>> call(DownloadImageParams params) {
    return repository.downloadImage(
      url: params.url,
      fileName: params.fileName,
      onProgress: params.onProgress,
    );
  }
}
