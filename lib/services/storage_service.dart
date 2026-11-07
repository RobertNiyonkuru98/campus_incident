import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/cloud_config.dart';

/// Thrown when an upload fails for a reason the user can act on.
class StorageException implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Picks photos and uploads them to Cloudinary. The only class that knows which
/// storage provider is in use.
class StorageService {
  StorageService({ImagePicker? picker, http.Client? client})
      : _picker = picker ?? ImagePicker(),
        _client = client ?? http.Client();

  final ImagePicker _picker;
  final http.Client _client;

  static const int maxPhotos = 3;

  /// Compressed on device before upload: 4 MB becomes roughly 300 KB.
  Future<XFile?> pick(ImageSource source) {
    return _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1280,
    );
  }

  /// Returns the public https URL stored in the report's `photoUrls`.
  Future<String> upload({required String uid, required XFile file}) async {
    if (!CloudConfig.isConfigured) {
      throw const StorageException(
        'Photo storage is not configured. Set cloudName and uploadPreset in '
        'lib/core/cloud_config.dart.',
      );
    }

    final Uri endpoint = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudConfig.cloudName}/image/upload',
    );

    final http.MultipartRequest request = http.MultipartRequest('POST', endpoint)
      ..fields['upload_preset'] = CloudConfig.uploadPreset
      ..fields['folder'] = 'campuscare/$uid'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          await file.readAsBytes(),
          filename: file.name,
        ),
      );

    final http.StreamedResponse response =
        await _client.send(request).timeout(const Duration(seconds: 60));
    final String body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StorageException(
        'Upload failed (HTTP ${response.statusCode}). Check that your upload '
        'preset is set to Unsigned and that the emulator has internet.',
      );
    }

    final Object? decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const StorageException('Unexpected response from the image host.');
    }

    final Object? url = decoded['secure_url'];
    if (url is! String || url.isEmpty) {
      throw const StorageException(
        'The upload succeeded but no image URL came back.',
      );
    }

    return url;
  }
}
