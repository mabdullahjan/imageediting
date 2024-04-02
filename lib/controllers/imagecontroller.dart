import 'package:get/get.dart';
import 'package:pnpimagecity/controllers/imageeditingscreen.dart';

class ImageController extends GetxController {
  final List<String> imagePaths = [
    'assets/image1.png',
    'assets/image2.png',
  ];

  void openImage(int index) {
    Get.to(ImageEditingScreen(imagePath: imagePaths[index]));
  }
}
