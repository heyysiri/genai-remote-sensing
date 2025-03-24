import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'constants.dart';
import 'theme.dart';

class FloodScreen extends StatefulWidget {
  const FloodScreen({super.key});
  @override
  State<FloodScreen> createState() => _FloodScreenState();
}

class _FloodScreenState extends State<FloodScreen> {
  int _currentIndex = 0;
  Uint8List? _selectedImageBytes;
  Uint8List? _groundTruthBytes;
  Uint8List? _predictedMaskBytes;
  Uint8List? _resultImageBytes;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Keep your existing methods
  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _groundTruthBytes = null;
        _predictedMaskBytes = null;
        _resultImageBytes = null;
      });
    }
  }

  Future<void> _detectFlood() async {
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload an image first.")),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      Map<String, String> headers = {'ngrok-skip-browser-warning': 'true'};

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://${url}:5000/detect"),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _selectedImageBytes!,
        filename: 'image.jpg',
      ));
      request.headers.addAll(headers);
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          _groundTruthBytes = base64Decode(jsonResponse['ground_truth']);
          _predictedMaskBytes = base64Decode(jsonResponse['predicted_mask']);
          _resultImageBytes = base64Decode(jsonResponse['result_image']);
        });
      } else {
        throw Exception("Error from server: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImageBytes = null;
      _groundTruthBytes = null;
      _predictedMaskBytes = null;
      _resultImageBytes = null;
    });
  }

  Widget _buildImageGrid() {
    final List<Map<String, dynamic>> images = [
      if (_selectedImageBytes != null)
        {'title': 'Uploaded Image', 'bytes': _selectedImageBytes},
      if (_predictedMaskBytes != null)
        {'title': 'Predicted Mask', 'bytes': _predictedMaskBytes},
      if (_resultImageBytes != null)
        {'title': 'Flood Detected Image', 'bytes': _resultImageBytes},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return Column(
          children: [
            Text(
              image['title'],
              style: AppTheme.subheadingStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    image['bytes'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flood Area Detection',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppTheme.backgroundColor],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "Upload an image to detect flood risks.",
                        style: AppTheme.bodyTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _uploadImage,
                        style: AppTheme.primaryButtonStyle,
                        icon: const Icon(Icons.upload),
                        label: const Text("Upload Image"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _detectFlood,
                        style: AppTheme.primaryButtonStyle,
                        icon: const Icon(Icons.search),
                        label: const Text("Detect Flood"),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (!_isLoading &&
                        (_selectedImageBytes != null ||
                            _groundTruthBytes != null ||
                            _predictedMaskBytes != null ||
                            _resultImageBytes != null))
                      _buildImageGrid(),
                    const SizedBox(
                        height: 80), // Add bottom padding for clear button
                  ],
                ),
              ),
            ),
            if (_selectedImageBytes != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _clearImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text("Clear Image"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
