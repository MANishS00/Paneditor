import 'dart:typed_data'; // For Uint8List
import 'dart:ui' as ui; // For image capturing and encoding
import 'dart:html' as html; // For web file picker
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart'; // For mobile image picking
import 'package:share_plus/share_plus.dart';

import 'constrant.dart'; // Your button component

class ImageTextOverlayPage extends StatefulWidget {
  const ImageTextOverlayPage({super.key});

  @override
  _ImageTextOverlayPageState createState() => _ImageTextOverlayPageState();
}

class _ImageTextOverlayPageState extends State<ImageTextOverlayPage> {
  String pantext = 'Enter Pan ';
  String nametext = 'Enter Name';
  String fathernametext = 'Enter Father Name';
  String dob = 'Date of Birth';
  bool _isLoading = false;

  Uint8List? _uploadedImage1;
  Uint8List? _uploadedImage2;
  Uint8List? _uploadedImage3;

  final GlobalKey _globalKey = GlobalKey();

  Future<void> _pickImage(int imageNumber) async {
    // Check if the platform is web
    if (kIsWeb) {
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        final files = uploadInput.files;
        if (files!.isNotEmpty) {
          final html.File file = files[0];
          final reader = html.FileReader();

          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((event) {
            setState(() {
              Uint8List imageData = reader.result as Uint8List;

              if (imageNumber == 1) {
                _uploadedImage1 = imageData;
              } else if (imageNumber == 2) {
                _uploadedImage2 = imageData;
              } else if (imageNumber == 3) {
                _uploadedImage3 = imageData;
              }
            });
          });
        }
      });
    } else {
      // Fallback for mobile
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() async {
          if (imageNumber == 1) {
            _uploadedImage1 = await pickedFile.readAsBytes();
          } else if (imageNumber == 2) {
            _uploadedImage2 = await pickedFile.readAsBytes();
          } else if (imageNumber == 3) {
            _uploadedImage3 = await pickedFile.readAsBytes();
          }
        });
      }
    }
  }

  Future<void> _captureAndSaveImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List buffer = byteData.buffer.asUint8List();

        if (kIsWeb) {
          // Web: Trigger a download for the image
          final blob = html.Blob([buffer]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", "image.png")
            ..click();
          html.Url.revokeObjectUrl(url);
        } else {
          // Mobile: Save image to gallery
          final result = await ImageGallerySaver.saveImage(buffer);
          if (result['isSuccess']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image saved to gallery!')),
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.deepPurple, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: SizedBox(
                      height: 727,
                      width: 1111,
                      // height: 370,
                      // width: 1090,
                      child: RepaintBoundary(
                        key: _globalKey,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              "https://ibb.co/ZJHbJB3",
                              height: 727,
                              width: 1111,
                              // width: 2222,
                              // height: 727,
                              fit: BoxFit.fill,
                            ),
                            _buildPositionedText(pantext.toUpperCase(), 362, 377, 42),
                            _buildPositionedText(nametext.toUpperCase(), 260, 57, 32),
                            _buildPositionedText(fathernametext.toUpperCase(), 160, 57, 32),
                            _buildPositionedText(dob.toUpperCase(), 38, 57, 32),
                            if (_uploadedImage1 != null)
                              Positioned(
                                top: 195,
                                left: 55,
                                child: Image.memory(
                                  _uploadedImage1!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            if (_uploadedImage2 != null)
                              Positioned(
                                bottom: 87,
                                left: 420,
                                child: Image.memory(
                                  _uploadedImage2!,
                                  width: 280,
                                  height: 78,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            if (_uploadedImage3 != null)
                              Positioned(
                                top: 209,
                                right: 62,
                                child: Image.memory(
                                  _uploadedImage3!,
                                  width: 302,
                                  height: 302,
                                  fit: BoxFit.fill,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFormSection(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Positioned _buildPositionedText(String text, double bottom, double left, double fontSize) {
    return Positioned(
      bottom: bottom,
      left: left,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      height: 570,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Button(text: "Photo", ontap: () => _pickImage(1)),
                Button(text: "Sign", ontap: () => _pickImage(2)),
                Button(text: "BARCode", ontap: () => _pickImage(3)),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField('PAN NUMBER', (value) => setState(() => pantext = value)),
            const SizedBox(height: 10),
            _buildTextField('FULL NAME', (value) => setState(() => nametext = value)),
            const SizedBox(height: 10),
            _buildTextField('FATHER NAME', (value) => setState(() => fathernametext = value)),
            const SizedBox(height: 10),
            _buildTextField('DATE OF BIRTH', (value) => setState(() => dob = value)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Button(text: "Save", ontap: _captureAndSaveImage, icons: Icons.save),
          ],
        ),
      ),
    );
  }
}
