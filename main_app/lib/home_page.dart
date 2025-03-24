import 'package:flutter/material.dart';
import 'package:frontend/crop.dart';
import 'package:frontend/crop_vgg16.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'imagecolrisation.dart'; // Import SARColorizationScreen
import 'flood_page.dart'; // Import FloodScreen
import 'constants.dart';
import 'theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String _result = ''; // To store prediction result

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

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

    final uri =
        Uri.parse('http://${url}:5000/colorize'); // Adjust URL to your backend
    final request = http.MultipartRequest("POST", uri);

    try {
      // Change the key from 'file' to 'image'
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
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
          _result = decodedData['class_name']
              .toString(); // Store the prediction result
        });
      } else {
        print('Failed to upload image: ${response.statusCode}');
        print(
            'Response body: ${await response.stream.bytesToString()}'); // Log response body for debugging
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Mapping'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppTheme.backgroundColor],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Classification Model',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 30),
                // VGG16 Classification Button
                _buildClassificationCard(
                  context: context,
                  title: 'Crop Classification (VGG16)',
                  description: 'Classify crops using the VGG16 model',
                  icon: Icons.grass,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CropVGG()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // VIT Classification Button
                _buildClassificationCard(
                  context: context,
                  title: 'Crop Classification (ViT)',
                  description:
                      'Classify crops using the Vision Transformer model',
                  icon: Icons.auto_awesome,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CropClassifier()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassificationCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTheme.bodyTextStyle,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
