import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/download/download_cubit.dart';
import '../bloc/download/download_state.dart';

class DownloadProgressDialog extends StatelessWidget {
  const DownloadProgressDialog({super.key});

  static void show(BuildContext context, {required String url, required String fileName}) {
    context.read<DownloadCubit>().startDownload(url: url, fileName: fileName);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<DownloadCubit>(),
        child: const DownloadProgressDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<DownloadCubit, DownloadState>(
      listener: (context, state) {
        if (state is DownloadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image saved successfully to ${state.filePath}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DownloadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: ${state.errorMessage}'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        double progress = 0.0;
        String statusText = 'Preparing download...';

        if (state is DownloadInProgress) {
          progress = state.progress;
          statusText = 'Downloading... ${(progress * 100).toStringAsFixed(0)}%';
        } else if (state is DownloadSuccess) {
          progress = 1.0;
          statusText = 'Download Complete!';
        } else if (state is DownloadFailure) {
          statusText = 'Error downloading image.';
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.file_download, color: Colors.indigoAccent),
              SizedBox(width: 8),
              Text('Downloading Image'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (state is DownloadInProgress || state is DownloadSuccess)
                    ? progress
                    : null,
                backgroundColor: theme.colorScheme.primary.withAlpha(40),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
                minHeight: 10,
              ),
              const SizedBox(height: 16),
              Text(
                statusText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<DownloadCubit>().reset();
                Navigator.of(context).pop();
              },
              child: Text(state is DownloadSuccess ? 'Done' : 'Close'),
            ),
          ],
        );
      },
    );
  }
}
