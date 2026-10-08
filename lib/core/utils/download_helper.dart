import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadHelper {
  final Dio dio;
  static const MethodChannel _nativeChannel = MethodChannel('com.example.gnxtace_assessment/gallery');

  DownloadHelper({Dio? dio}) : dio = dio ?? Dio();

  Future<String> downloadImage({
    required String url,
    required String fileName,
    required void Function(int received, int total) onProgress,
  }) async {
    try {
      // Request storage permissions if on Android / iOS
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        if (Platform.isAndroid && !status.isGranted) {
          await Permission.photos.request();
        }
      }

      Directory saveDir;
      if (!kIsWeb) {
        saveDir = await getTemporaryDirectory();
      } else {
        throw UnsupportedError('Download feature is optimized for desktop and mobile.');
      }

      final cleanFileName = fileName.replaceAll(RegExp(r'[^\w\.-]'), '_');
      final tempFilePath = '${saveDir.path}/$cleanFileName.jpg';

      // 1. Download image file using Dio stream
      await dio.download(
        url,
        tempFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received, total);
          }
        },
      );

      // 2. Invoke Native MethodChannel on Android to save to MediaStore (Pictures Gallery)
      if (!kIsWeb && Platform.isAndroid) {
        try {
          final String? nativeSavedPath = await _nativeChannel.invokeMethod('saveImageToGallery', {
            'filePath': tempFilePath,
          });
          if (nativeSavedPath != null && nativeSavedPath.isNotEmpty) {
            return nativeSavedPath;
          }
        } catch (e) {
          debugPrint('[MethodChannel Save Error] $e');
        }
      }

      return tempFilePath;
    } catch (e) {
      debugPrint('[Download Error] $e');
      rethrow;
    }
  }
}
