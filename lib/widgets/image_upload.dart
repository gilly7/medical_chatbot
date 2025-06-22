import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageUpload extends StatelessWidget {
  final Function(String) onImageSelected;

  const ImageUpload({super.key, required this.onImageSelected});

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImageSelected(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(Icons.image), onPressed: _pickImage);
  }
}
