import 'package:equatable/equatable.dart';

abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {
  const DownloadInitial();
}

class DownloadInProgress extends DownloadState {
  final double progress; // 0.0 to 1.0

  const DownloadInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DownloadSuccess extends DownloadState {
  final String filePath;

  const DownloadSuccess(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class DownloadFailure extends DownloadState {
  final String errorMessage;

  const DownloadFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
