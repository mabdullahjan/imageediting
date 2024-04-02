import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pnpimagecity/controllers/imagecontroller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageController imageController = Get.put(ImageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Dashboard'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: imageController.imagePaths.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              imageController.openImage(index);
            },
            child: Card(
              elevation: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      imageController.imagePaths[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        // Handle button press
                      },
                      child: Text('Template ${index + 1}'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
