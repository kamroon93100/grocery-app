import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  final ImagePicker _picker = ImagePicker();
  static const String _imgurClientId = '546c25a59c58ad7';

  Future<XFile?> pickImage({bool fromCamera = false}) async {
    try {
      return await _picker.pickImage(
        source:        fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality:  85,
        maxWidth:      800,
        maxHeight:     800,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadToImgur(XFile file) async {
    try {
      final bytes  = await File(file.path).readAsBytes();
      final base64 = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgur.com/3/image'),
        headers: {
          'Authorization': 'Client-ID $_imgurClientId',
          'Content-Type':  'application/x-www-form-urlencoded',
        },
        body: {'image': base64, 'type': 'base64'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['link'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> pickAndUpload({bool fromCamera = false}) async {
    final file = await pickImage(fromCamera: fromCamera);
    if (file == null) return null;
    return await uploadToImgur(file);
  }
}
