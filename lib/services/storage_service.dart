import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String bucketName = 'images-de-recettes';

  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final path =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _supabase.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: false,
          ),
        );

    return _supabase.storage
        .from(bucketName)
        .getPublicUrl(path);
  }

  /// Extrait le chemin réel du fichier depuis son URL Supabase.
  String _getStoragePath(String imageUrl) {
    final uri = Uri.parse(imageUrl);

    const marker = '/storage/v1/object/public/';

    final fullPath = uri.path;

    final markerIndex = fullPath.indexOf(marker);

    if (markerIndex == -1) {
      throw Exception('URL Supabase Storage invalide');
    }

    final pathAfterMarker =
        fullPath.substring(markerIndex + marker.length);

    final bucketPrefix = '$bucketName/';

    if (!pathAfterMarker.startsWith(bucketPrefix)) {
      throw Exception('L\'image n’appartient pas au bon bucket');
    }

    return pathAfterMarker.substring(bucketPrefix.length);
  }

  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.trim().isEmpty) return;

    final path = _getStoragePath(imageUrl);

    await _supabase.storage.from(bucketName).remove([
      path,
    ]);
  }
}