import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/download_image_usecase.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  final DownloadImageUseCase downloadImageUseCase;

  DownloadCubit({required this.downloadImageUseCase})
      : super(const DownloadInitial());

  Future<void> startDownload({
    required String url,
    required String fileName,
  }) async {
    emit(const DownloadInProgress(0.0));

    final result = await downloadImageUseCase(
      DownloadImageParams(
        url: url,
        fileName: fileName,
        onProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            emit(DownloadInProgress(progress));
          }
        },
      ),
    );

    result.fold(
      (failure) => emit(DownloadFailure(failure.message)),
      (filePath) => emit(DownloadSuccess(filePath)),
    );
  }

  void reset() {
    emit(const DownloadInitial());
  }
}
