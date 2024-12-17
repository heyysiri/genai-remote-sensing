import 'package:flutter/material.dart';
import 'package:frontend/crop.dart';
import 'package:frontend/crop_vgg16.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'imagecolrisation.dart'; // Import SARColorizationScreen
import 'flood_page.dart'; // Import FloodScreen

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String _result = ''; // To store prediction result

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _result = ''; // Clear previous result when a new image is picked
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Method to send the image to the backend
  Future<void> _sendImageToBackend() async {
    if (_image == null) {
      print('No image to send.');
      return;
    }

    final uri = Uri.parse('https://7a5f-27-59-63-130.ngrok-free.app/colorize'); // Adjust URL to your backend
    final request = http.MultipartRequest("POST", uri);
    
    try {
      // Change the key from 'file' to 'image'
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path)); 
    } catch (e) {
      print('Error adding image to request: $e');
      return;
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        setState(() {
          _result = decodedData['class_name'].toString(); // Store the prediction result
        });
      } else {
        print('Failed to upload image: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}'); // Log response body for debugging
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Button to navigate to Crop Classification using VGG16
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CropVGG()),
                );
              },
              child: Text('Go to Crop classification using VGG16'),
            ),
            // Button to navigate to CropClassification using VIT
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CropClassifier()),
                );
              },
              child: Text('Go to Crop classification using VIT'),
            ),
            SizedBox(height: 50),
            // Button to navigate to SARColorizationScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SARColorizationScreen()),
                );
              },
              child: Text('Go to SAR Image Colorization'),
            ),
            SizedBox(height: 16),
            // Button to navigate to FloodScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FloodScreen()),
                );
              },
              child: Text('Go to Flood Detection'),
            ),
          ],
        ),
      ),
    );
  }
}