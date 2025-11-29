import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ImageDownloader {
  static Future<bool> downloadImage(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.bodyBytes),
          quality: 100,
          name: "photo_idea_${DateTime.now().millisecondsSinceEpoch}"
        );
        return result['isSuccess'] ?? false;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
