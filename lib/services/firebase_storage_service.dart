import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
// Upload/download files từ Firebase Storage
class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final _storage = FirebaseStorage.instance;

            Future<String?> uploadPostImage(File imageFile, String postId) async {
    try {
      final fileName = path.basename(imageFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('posts/$postId/$timestamp-$fileName');

      
      final uploadTask = await ref.putFile(imageFile);
      
      
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

            Future<String?> uploadAvatar(File imageFile, String userId) async {
    try {
      final fileName = path.basename(imageFile.path);
      final ref = _storage.ref().child('avatars/$userId/$fileName');

      
      final uploadTask = await ref.putFile(imageFile);
      
      
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

            Future<List<String>> uploadMultiplePostImages(
    List<File> imageFiles,
    String postId,
  ) async {
    final urls = <String>[];

    for (var imageFile in imageFiles) {
      final url = await uploadPostImage(imageFile, postId);
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

        Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

    Future<FullMetadata?> getImageMetadata(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      return await ref.getMetadata();
    } catch (e) {
      return null;
    }
  }

              Future<Map<String, String>?> uploadXFile(
    XFile xFile, 
    String folder, {
    void Function(double)? onProgress,
  }) async {
    try {
      
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to upload files');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = xFile.name;
      final fileId = '$timestamp-$fileName';
      final ref = _storage.ref().child('$folder/$fileId');


      
      final bytes = await xFile.readAsBytes();
      
      
      final uploadTask = ref.putData(bytes);

      
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      
      await uploadTask;
      
      
      final downloadUrl = await ref.getDownloadURL();

      return {
        'id': fileId,
        'url': downloadUrl,
      };
    } catch (e) {
      
      
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
      }
      return null;
    }
  }
}

