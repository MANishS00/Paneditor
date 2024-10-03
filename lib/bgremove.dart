import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:image_picker/image_picker.dart';



class ImageBackgroundRemover extends StatefulWidget {
  const ImageBackgroundRemover({super.key});

  @override
  _ImageBackgroundRemoverState createState() => _ImageBackgroundRemoverState();
}

class _ImageBackgroundRemoverState extends State<ImageBackgroundRemover> {
  Uint8List? _uploadedImage;
  Uint8List? _bgRemovedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Read the image bytes asynchronously
      _uploadedImage = await pickedFile.readAsBytes();

      // Remove background after image is picked
      await _removeBackground();
    }
  }

  Future<void> _removeBackground() async {
    if (_uploadedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    // Replace 'YOUR_API_KEY' with your remove.bg API key
    const String apiKey = 'HX39o5zgCmmWGuMqmGQzPnvj';
    final Uri url = Uri.parse('https://api.remove.bg/v1.0/removebg');

    final http.MultipartRequest request = http.MultipartRequest('POST', url);
    request.headers['X-Api-Key'] = apiKey;

    request.files.add(http.MultipartFile.fromBytes(
      'image_file',
      _uploadedImage!,
      filename: 'uploaded_image.png',
    ));

    request.fields['size'] = 'auto'; // Optional field

    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final Uint8List result = await response.stream.toBytes();
      setState(() {
        _bgRemovedImage = result;
      });
    } else {
      print('Error: ${response.reasonPhrase}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Image Background'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _uploadedImage != null
                    ? Image.memory(
                  _uploadedImage!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                )
                    : const Text('No Image Selected'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Upload Image'),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : _bgRemovedImage != null
                    ? Column(
                  children: [
                    const Text('Background Removed:'),
                    Container(
                      height: 400,
                      width: 500,
                      child: Image.memory(
                        _bgRemovedImage!,
                        width: 300,
                        height: 300,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                )
                    : const Text('Background Not Removed Yet'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
