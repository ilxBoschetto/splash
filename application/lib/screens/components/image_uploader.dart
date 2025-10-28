import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

class ImageUploader extends StatelessWidget {
  final XFile? selectedImage;
  final void Function(XFile? image) onImagePicked;

  const ImageUploader({
    super.key,
    required this.selectedImage,
    required this.onImagePicked,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onImagePicked(image); // notifica al parent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedImage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Image.file(
              File(selectedImage!.path),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ElevatedButton.icon(
          onPressed: () => _pickImage(context),
          icon: const Icon(Icons.image),
          label: Text('drinking_fountain.upload_image'.tr()),
        ),
      ],
    );
  }
}
