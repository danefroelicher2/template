// lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  // Upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    if (!_authService.isAuthenticated) return null;

    final userId = _authService.userId;
    final ref = _storage.ref().child('profile_images/$userId.jpg');

    try {
      // Upload file
      await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Delete profile image
  Future<bool> deleteProfileImage() async {
    if (!_authService.isAuthenticated) return false;

    final userId = _authService.userId;
    final ref = _storage.ref().child('profile_images/$userId.jpg');

    try {
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }
}
