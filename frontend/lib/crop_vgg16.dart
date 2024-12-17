import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropVGG extends StatefulWidget {
  @override
  _CropVGGState createState() => _CropVGGState();
}

class _CropVGGState extends State<CropVGG> {
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

  const headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true', // Custom header if needed for ngrok
  };

  final uri = Uri.parse('https://30d5-2401-4900-6768-5dea-1400-950b-1424-93db.ngrok-free.app/predict');

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
        _result = decodedResponse['predicted_class_name']; // Store the prediction result
      });
    } else {
      print('Failed to upload image: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending image: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vgg16 Classification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display selected image or a message if no image is selected
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!, height: 200, width: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _sendImageToBackend,
              child: Text('Send Image for prediction'),
            ),
            SizedBox(height: 24),
            // Box to display the prediction result
            _result.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prediction Result:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0), // Space between title and result
                        Text(
                          _result,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(), // Only show this container if _result is not empty
          ],
        ),
      ),
    );
  }
}
