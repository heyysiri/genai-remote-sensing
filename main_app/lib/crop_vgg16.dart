import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'theme.dart';

class CropVGG extends StatefulWidget {
  const CropVGG({super.key});

  @override
  _CropVGGState createState() => _CropVGGState();
}

class _CropVGGState extends State<CropVGG> {
  File? _image;
  String _result = ''; // To store prediction result
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
    });

    const headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Custom header if needed for ngrok
    };

    final uri = Uri.parse('http://${url}:5000/predict');

    try {
      // Read the image file as bytes and encode to Base64
      final imageBytes = await File(_image!.path).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Create JSON payload
      final payload = jsonEncode({'image': base64Image});

      // Send POST request
      final response = await http.post(
        uri,
        headers: headers,
        body: payload,
      );

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        final decodedResponse = json.decode(response.body);

        setState(() {
          _result = decodedResponse[
              'predicted_class_name']; // Store the prediction result
        });
      } else {
        print('Failed to upload image: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VGG16 Classification'),
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
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display selected image or a placeholder
                if (_image == null)
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Buttons with consistent width
                SizedBox(
                  width: 250,
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    style: AppTheme.primaryButtonStyle,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: 250,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendImageToBackend,
                    style: AppTheme.primaryButtonStyle,
                    icon: _isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.upload),
                    label: Text(_isLoading
                        ? 'Processing...'
                        : 'Send Image for Prediction'),
                  ),
                ),
                const SizedBox(height: 32),

                // Result container with fixed width to prevent layout shift
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _result.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Prediction Result:',
                                style: AppTheme.subheadingStyle,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  _result,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
