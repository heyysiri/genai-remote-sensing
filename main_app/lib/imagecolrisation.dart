import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'theme.dart';

class SARColorizationScreen extends StatefulWidget {
  const SARColorizationScreen({super.key});

  @override
  _SARColorizationScreenState createState() => _SARColorizationScreenState();
}

class _SARColorizationScreenState extends State<SARColorizationScreen> {
  File? _selectedImage;
  String? _colorizedImageUrl;
  bool _isLoading = false;
  int _currentIndex = 0;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _colorizedImageUrl = null;
      });
    }
  }

  Future<void> _colorizeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('http://${url}:5000/colorize');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.toBytes();
        final base64Image = base64Encode(responseBody);

        setState(() {
          _colorizedImageUrl = "data:image/png;base64,$base64Image";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to colorize image: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _downloadImage() {
    // Show a message that the feature is temporarily disabled
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download feature is temporarily disabled'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAR Image Colorization'),
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
                if (_selectedImage == null)
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
                        _selectedImage!,
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
                    onPressed: _isLoading ? null : _colorizeImage,
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
                        : const Icon(Icons.colorize),
                    label:
                        Text(_isLoading ? 'Processing...' : 'Colorize Image'),
                  ),
                ),
                const SizedBox(height: 32),

                // Display the colorized image (if available)
                if (_colorizedImageUrl != null)
                  Column(
                    children: [
                      const Text(
                        'Colorized Image',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
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
                          child: Image.memory(
                            base64Decode(_colorizedImageUrl!.split(',')[1]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Download button with consistent width
                      SizedBox(
                        width: 250,
                        child: ElevatedButton.icon(
                          style: AppTheme.primaryButtonStyle,
                          onPressed: _downloadImage,
                          icon: const Icon(Icons.download),
                          label: const Text('Download Image'),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // FID score in pill container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'FID SCORE: 310',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
