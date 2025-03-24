import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class CropClassifier extends StatefulWidget {
  const CropClassifier({super.key});

  @override
  _CropClassifierState createState() => _CropClassifierState();
}

class _CropClassifierState extends State<CropClassifier> {
  File? _image;
  String? _prediction;
  String? _errorMessage;
  int _currentIndex = 0;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          _errorMessage = null; 
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      print('No image to upload');
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://30d5-2401-4900-6768-5dea-1400-950b-1424-93db.ngrok-free.app/classifyVit'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        var resBody = json.decode(responseBody.body);
        setState(() {
          _prediction = resBody['predicted_class_name'];
          _errorMessage = null; 
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to get prediction. Status code: ${response.statusCode}';
        });
        print('Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Server error: $e';
      });
      print('Error uploading image: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop Classification using VIT',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null)
              Image.file(
                _image!,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 300,
                color: Colors.white,
                child: const Center(
                  child: Text('No image selected'),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Select Image'),
              onPressed: _pickImage,
            
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload Image'),
              onPressed: _uploadImage,
            ),
            const SizedBox(height: 16),
            if (_prediction != null)
              Text(
                'Prediction: $_prediction',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            if (_errorMessage != null)
              Text(
                'Error: $_errorMessage',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}