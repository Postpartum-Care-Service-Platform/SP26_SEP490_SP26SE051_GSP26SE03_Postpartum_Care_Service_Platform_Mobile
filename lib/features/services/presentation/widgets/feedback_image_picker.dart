import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';

/// Feedback Image Picker Widget
/// Allows user to select and preview multiple images
class FeedbackImagePicker extends StatefulWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>> onImagesChanged;
  final int maxImages;

  const FeedbackImagePicker({
    super.key,
    required this.imagePaths,
    required this.onImagesChanged,
    this.maxImages = 5,
  });

  @override
  State<FeedbackImagePicker> createState() => _FeedbackImagePickerState();
}

class _FeedbackImagePickerState extends State<FeedbackImagePicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (widget.imagePaths.length >= widget.maxImages) {
        AppToast.showWarning(
          context,
          message: 'Bạn chỉ có thể thêm tối đa ${widget.maxImages} ảnh',
        );
        return;
      }

      final image = await _picker.pickImage(source: source);
      if (image != null && mounted) {
        final newPaths = [...widget.imagePaths, image.path];
        widget.onImagesChanged(newPaths);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context,
          message: 'Không thể chọn ảnh: ${e.toString()}',
        );
      }
    }
  }

  void _removeImage(int index) {
    final newPaths = List<String>.from(widget.imagePaths);
    newPaths.removeAt(index);
    widget.onImagesChanged(newPaths);
  }

  void _showImageSourceSheet() {
    final scale = AppResponsive.scaleFactor(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16 * scale)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text(AppStrings.takePhoto),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text(AppStrings.chooseFromLibrary),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image grid
        if (widget.imagePaths.isNotEmpty)
          SizedBox(
            height: 100 * scale,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100 * scale,
                  height: 100 * scale,
                  margin: EdgeInsets.only(right: 8 * scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: Image.file(
                          File(widget.imagePaths[index]),
                          width: 100 * scale,
                          height: 100 * scale,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4 * scale,
                        right: 4 * scale,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16 * scale,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 12 * scale),
        // Add image button
        if (widget.imagePaths.length < widget.maxImages)
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 20 * scale,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    'Thêm ảnh (${widget.imagePaths.length}/${widget.maxImages})',
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
