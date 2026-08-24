import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

/// Service for compressing, uploading, and managing images on BunnyCDN Storage Zone.
class BunnyCdnService {
  // BunnyCDN Configuration
  static const String _storageZoneName = 'booknglow-media';
  static const String _folderName = 'user-images';
  static const String _accessKey = 'b059ca2b-7223-417d-ba87b92a4d7e-6417-4a70';
  static const String _storageHostname = 'storage.bunnycdn.com';
  static const String _cdnHostname = 'booknglow-media.b-cdn.net';

  /// Compresses an image file to a lightweight JPEG format (target max 800x800, quality 75)
  /// before uploading to BunnyCDN.
  static Future<Uint8List> compressImage(File file) async {
    try {
      final originalSize = await file.length();
      debugPrint(
        '📸 [BunnyCdnService] Original image size: ${(originalSize / 1024).toStringAsFixed(1)} KB',
      );

      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
            file.absolute.path,
            minWidth: 800,
            minHeight: 800,
            quality: 75,
            format: CompressFormat.jpeg,
          );

      if (compressedBytes != null && compressedBytes.isNotEmpty) {
        final compressedSize = compressedBytes.length;
        final percentSaved = ((1 - (compressedSize / originalSize)) * 100)
            .toStringAsFixed(1);
        debugPrint(
          '✅ [BunnyCdnService] Compressed image size: ${(compressedSize / 1024).toStringAsFixed(1)} KB (Saved: $percentSaved%)',
        );
        return compressedBytes;
      }
    } catch (e) {
      debugPrint(
        '⚠️ [BunnyCdnService] Compression error, falling back to original file bytes: $e',
      );
    }

    return await file.readAsBytes();
  }

  /// Deletes an existing image from BunnyCDN storage given its full CDN URL or filename.
  /// Used for automated storage cleanup when replacing or removing a profile photo.
  static Future<bool> deleteImageByUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) return false;

    final trimmed = imageUrl.trim();

    // Check if the URL points to BunnyCDN storage / CDN
    if (!trimmed.contains('b-cdn.net') &&
        !trimmed.contains('bunnycdn.com') &&
        !trimmed.contains(_storageZoneName)) {
      debugPrint(
        'ℹ️ [BunnyCdnService] Skipping delete: URL is not a BunnyCDN image ($trimmed)',
      );
      return false;
    }

    try {
      final uri = Uri.tryParse(trimmed);
      if (uri == null) return false;

      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return false;

      final fileName = pathSegments.last;
      if (fileName.isEmpty) return false;

      final deleteUri = Uri.parse(
        'https://$_storageHostname/$_storageZoneName/$_folderName/$fileName',
      );

      debugPrint(
        '🗑️ [BunnyCdnService] Deleting old image from BunnyCDN: $deleteUri',
      );

      final response = await http.delete(
        deleteUri,
        headers: {'AccessKey': _accessKey},
      );

      debugPrint(
        '🔥 [BunnyCdnService] Delete response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 404) {
        debugPrint(
          '✅ [BunnyCdnService] Old image cleaned up from BunnyCDN storage: $fileName',
        );
        return true;
      } else {
        debugPrint(
          '⚠️ [BunnyCdnService] Failed to delete image: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [BunnyCdnService] Error deleting image from BunnyCDN: $e');
      return false;
    }
  }

  /// Compresses the given [imageFile] and uploads it to BunnyCDN under `user-images/`.
  /// If [oldImageUrl] is provided, it automatically cleans up the previous image from BunnyCDN.
  /// Returns the public CDN URL on success (e.g. `https://booknglow-media.b-cdn.net/user-images/user_xxx.jpg`).
  static Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
    String? oldImageUrl,
  }) async {
    try {
      // 1. Compress image first
      final Uint8List compressedBytes = await compressImage(imageFile);

      // 2. Generate a clean unique timestamped filename (ensures immediate CDN cache freshness)
      final cleanUid = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
      final fileName =
          'user_${cleanUid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 3. Construct BunnyCDN Storage API endpoint URL
      final uploadUri = Uri.parse(
        'https://$_storageHostname/$_storageZoneName/$_folderName/$fileName',
      );

      debugPrint(
        '🚀 [BunnyCdnService] Uploading compressed image to: $uploadUri',
      );

      // 4. Execute HTTP PUT upload
      final response = await http.put(
        uploadUri,
        headers: {
          'AccessKey': _accessKey,
          'Content-Type': 'application/octet-stream',
        },
        body: compressedBytes,
      );

      debugPrint(
        '🔥 [BunnyCdnService] BunnyCDN upload response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final cdnUrl = 'https://$_cdnHostname/$_folderName/$fileName';
        debugPrint(
          '✅ [BunnyCdnService] Successfully uploaded profile photo to BunnyCDN! URL: $cdnUrl',
        );

        // 5. Automated Storage Cleanup: Remove previous image if exists
        if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
          deleteImageByUrl(oldImageUrl);
        }

        return cdnUrl;
      } else {
        debugPrint(
          '❌ [BunnyCdnService] Upload failed: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to upload to BunnyCDN (Status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e, stack) {
      debugPrint(
        '❌ [BunnyCdnService] Error uploading profile image: $e\n$stack',
      );
      rethrow;
    }
  }
}
