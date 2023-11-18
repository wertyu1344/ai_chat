import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class FirebaseStorageServices {
  var firebaseStorage = FirebaseStorage.instance;
  Future<Uint8List?> getFortuneTellersImage(String id) async {
    try {
      return await firebaseStorage.ref().child('images/$id.jpg').getData();
    } catch (e) {
      print("gelen id $id");

      print("images yakalama hata $e");
    }
    return null;
  }

  Future<String?> getFortuneTellersImageUrl(String id) async {
    return await firebaseStorage.ref().child('images/$id').getDownloadURL();
  }
}
