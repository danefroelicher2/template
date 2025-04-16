// lib/widgets/profile_image_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

class ProfileImagePicker extends StatefulWidget {
  final double radius;
  final Function(String)? onImageUploaded;

  const ProfileImagePicker({Key? key, this.radius = 50, this.onImageUploaded})
    : super(key: key);

  @override
  _ProfileImagePickerState createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile;

    return Stack(
      children: [
        // Profile image
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: Colors.blue.shade100,
          backgroundImage:
              profile?.photoURL != null
                  ? NetworkImage(profile!.photoURL!)
                  : null,
          child:
              profile?.photoURL == null
                  ? Icon(Icons.person, size: widget.radius, color: Colors.blue)
                  : null,
        ),

        // Edit button
        Positioned(
          bottom: 0,
          right: 0,
          child:
              _isLoading
                  ? Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _selectAndUploadImage,
                      iconSize: 24,
                      padding: EdgeInsets.all(8),
                      constraints:
                          BoxConstraints(), // Remove minimum size constraints
                    ),
                  ),
        ),
      ],
    );
  }

  Future<void> _selectAndUploadImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Show options to take a photo or choose from gallery
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (authProvider.profile?.photoURL != null)
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Remove Photo'),
                  onTap: () => Navigator.pop(context, null),
                ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      // User either canceled or wants to remove the photo
      if (authProvider.profile?.photoURL != null) {
        _removeProfileImage();
      }
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storageService = StorageService();
      final downloadUrl = await storageService.uploadProfileImage(
        File(imageFile.path),
      );

      if (downloadUrl != null) {
        await authProvider.updateProfile(photoURL: downloadUrl);

        if (widget.onImageUploaded != null) {
          widget.onImageUploaded!(downloadUrl);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile image')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeProfileImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final storageService = StorageService();
      await storageService.deleteProfileImage();
      await authProvider.updateProfile(photoURL: null);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove profile image')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
