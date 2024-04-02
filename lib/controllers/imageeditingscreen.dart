import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageEditingScreen extends StatefulWidget {
  final String imagePath;

  ImageEditingScreen({required this.imagePath});

  @override
  _ImageEditingScreenState createState() => _ImageEditingScreenState();
}

class _ImageEditingScreenState extends State<ImageEditingScreen> {
  Color _backgroundColor = Colors.white;
  String _text = '';
  String _importedImagePath = '';
  Offset _importedImagePosition = Offset(0, 0);
  double _importedImageScale = 1.0;
  Offset _baseImagePosition = Offset(0, 0);
  double _baseImageScale = 1.0;

  Future<void> _importImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _importedImagePath = pickedFile.path;
        _importedImagePosition = Offset(0, 0);
        _importedImageScale = 1.0;
      });
    }
  }

  img.Image _resizeImage(img.Image image, double maxWidth, double maxHeight) {
    if (image.width <= maxWidth && image.height <= maxHeight) {
      return image;
    }
    double aspectRatio = image.width / image.height;
    double newWidth = image.width.toDouble();
    double newHeight = image.height.toDouble();
    if (newWidth > maxWidth) {
      newWidth = maxWidth;
      newHeight = newWidth / aspectRatio;
    }
    if (newHeight > maxHeight) {
      newHeight = maxHeight;
      newWidth = newHeight * aspectRatio;
    }
    return img.copyResize(image,
        width: newWidth.toInt(), height: newHeight.toInt());
  }

  Future<void> _saveImage() async {
    if (_importedImagePath.isNotEmpty) {
      final Directory? extDir = await getExternalStorageDirectory();
      final String dirPath = '${extDir!.path}/Pictures';
      final String filePath = '$dirPath/edited_image.png';

      final img.Image baseImage =
          img.decodeImage(File(widget.imagePath).readAsBytesSync())!;
      final img.Image importedImage =
          img.decodeImage(File(_importedImagePath).readAsBytesSync())!;

      final img.Image resizedImage = _resizeImage(importedImage,
          baseImage.width.toDouble(), baseImage.height.toDouble());

      final img.Image newImage = img.copyInto(baseImage, resizedImage,
          dstX: _importedImagePosition.dx.toInt(),
          dstY: _importedImagePosition.dy.toInt());

      final File imageFile = File(filePath)
        ..writeAsBytesSync(img.encodePng(newImage));

      final saved = await ImageGallerySaver.saveFile(filePath);

      if (saved != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Image saved to gallery')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save image')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No image selected')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Editing'),
      ),
      body: Stack(
        children: [
          Container(
            color: _backgroundColor,
            child: Center(
              child: Stack(
                children: [
                  InteractiveViewer(
                    boundaryMargin: EdgeInsets.all(double.infinity),
                    minScale: 0.1,
                    maxScale: 2.0,
                    transformationController: TransformationController(),
                    onInteractionUpdate: (details) {
                      setState(() {
                        _baseImageScale = details.scale;
                        _baseImagePosition += details.focalPointDelta;
                      });
                    },
                    child: Transform.scale(
                      scale: _baseImageScale,
                      child: Image.asset(
                        widget.imagePath,
                        height: 600,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    child: Text(
                      _text,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _importedImagePath.isNotEmpty
                      ? Positioned(
                          left: _importedImagePosition.dx,
                          top: _importedImagePosition.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                double newLeft = _importedImagePosition.dx +
                                    details.delta.dx;
                                double newTop = _importedImagePosition.dy +
                                    details.delta.dy;
                                if (newLeft < 0) newLeft = 0;
                                if (newTop < 0) newTop = 0;
                                _importedImagePosition =
                                    Offset(newLeft, newTop);
                              });
                            },
                            child: InteractiveViewer(
                              boundaryMargin: EdgeInsets.all(double.infinity),
                              minScale: 0.1,
                              maxScale: 2.0,
                              child: ClipOval(
                                child: Image.file(
                                  File(_importedImagePath),
                                  fit: BoxFit.fill,
                                  width: 100, // Set the size of the oval
                                  height: 100,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.color_lens, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Select Background Color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: _backgroundColor,
                              onColorChanged: (color) {
                                setState(() {
                                  _backgroundColor = color;
                                });
                              },
                              showLabel: true,
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.text_fields, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Add Text'),
                          content: TextField(
                            onChanged: (value) {
                              _text = value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter text',
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.image, color: Colors.white),
                    onPressed: () {
                      _importImage();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.save, color: Colors.white),
                    onPressed: () {
                      _saveImage();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
