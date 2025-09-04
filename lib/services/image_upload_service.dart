import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image/image.dart' as img;
import '../config/cloudinary_config.dart';

class ImageUploadService {
  static Future<String> uploadImage(File imageFile) async {
    try {
      // Compress and resize image
      final compressedImage = await _compressImage(imageFile);
      
      // Upload to Cloudinary
      final response = await CloudinaryPublic(
        CloudinaryConfig.cloudName,
        CloudinaryConfig.uploadPreset,
      ).uploadFile(
        CloudinaryFile.fromFile(
          compressedImage.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<String> uploadImageBytes(Uint8List imageBytes) async {
    try {
      // Compress and resize image bytes
      final compressedBytes = await _compressImageBytes(imageBytes);
      
      // Create temporary file for upload
      final tempFile = File('temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);
      
      // Upload to Cloudinary
      final response = await CloudinaryPublic(
        CloudinaryConfig.cloudName,
        CloudinaryConfig.uploadPreset,
      ).uploadFile(
        CloudinaryFile.fromFile(
          tempFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      // Clean up temp file
      await tempFile.delete();
      
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<File> _compressImage(File imageFile) async {
    try {
      // Read image
      final image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) throw Exception('Failed to decode image');
      
      // Resize image to max dimensions
      final resizedImage = img.copyResize(
        image,
        width: 1024,
        height: 1024,
        interpolation: img.Interpolation.linear,
      );
      
      // Compress with quality 85
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      
      // Create temporary file
      final tempFile = File('${imageFile.path}_compressed.jpg');
      await tempFile.writeAsBytes(compressedBytes);
      
      return tempFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  static Future<Uint8List> _compressImageBytes(Uint8List imageBytes) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');
      
      // Resize image to max dimensions
      final resizedImage = img.copyResize(
        image,
        width: 1024,
        height: 1024,
        interpolation: img.Interpolation.linear,
      );
      
      // Compress with quality 85
      return img.encodeJpg(resizedImage, quality: 85);
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }
} 