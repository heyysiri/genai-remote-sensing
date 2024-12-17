// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class FloodScreen extends StatefulWidget {
//   const FloodScreen({super.key});
//   @override
//   State<FloodScreen> createState() =>
//       _FloodScreenState();
// }

// class _FloodScreenState extends State<FloodScreen> {
//     int _currentIndex = 0;
//   Uint8List? _selectedImageBytes;
//   Uint8List? _groundTruthBytes;
//   Uint8List? _predictedMaskBytes;
//   Uint8List? _resultImageBytes;
//   bool _isLoading = false;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _uploadImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final bytes = await pickedFile.readAsBytes();
//       setState(() {
//         _selectedImageBytes = bytes;
//         _groundTruthBytes = null;
//         _predictedMaskBytes = null;
//         _resultImageBytes = null;
//       });
//     }
//   }

//   Future<void> _detectFlood() async {
//   if (_selectedImageBytes == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Please upload an image first.")),
//     );
//     return;
//   }

//   try {
//     setState(() {
//       _isLoading = true;
//     });

//     // Add more detailed logging
//     print('Image bytes length: ${_selectedImageBytes!.length}');
// Map<String, String> headers = {
//       'ngrok-skip-browser-warning':'true'
//     };
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse("https://30d5-2401-4900-6768-5dea-1400-950b-1424-93db.ngrok-free.app/detect"),
//     );
//         request.headers.addAll(headers);

//     request.files.add(http.MultipartFile.fromBytes(
//       'image',
//       _selectedImageBytes!,
//       filename: 'image.jpg',
//     ));

//     // Log full request details
//     print('Request URL: ${request.url}');
//     print('Request Files: ${request.files}');

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     // More comprehensive error logging
//     print('Response Status Code: ${response.statusCode}');
//     print('Response Body: ${response.body}');

//     if (response.statusCode == 200) {
//       final jsonResponse = jsonDecode(response.body);
//       setState(() {
//         _groundTruthBytes = base64Decode(jsonResponse['ground_truth']);
//         _predictedMaskBytes = base64Decode(jsonResponse['predicted_mask']);
//         _resultImageBytes = base64Decode(jsonResponse['result_image']);
//       });
//     } else {
//       throw Exception("Error from server: ${response.body}");
//     }
//   } catch (e) {
//     print('Detailed Error: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: $e")),
//     );
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }

//   void _clearImage() {
//     setState(() {
//       _selectedImageBytes = null;
//       _groundTruthBytes = null;
//       _predictedMaskBytes = null;
//       _resultImageBytes = null;
//     });
//   }

//   Widget _buildImageGrid() {
//   final List<Map<String, dynamic>> images = [
//     if (_selectedImageBytes != null)
//       {'title': 'Uploaded Image', 'bytes': _selectedImageBytes},
//     if (_predictedMaskBytes != null)
//       {'title': 'Predicted Mask', 'bytes': _predictedMaskBytes},
//     if (_resultImageBytes != null)
//       {'title': 'Flood Detected Image', 'bytes': _resultImageBytes},
//   ];

//   return GridView.builder(
//     shrinkWrap: true,
//     physics: const NeverScrollableScrollPhysics(),
//     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount: 2,
//       crossAxisSpacing: 10,
//       mainAxisSpacing: 10,
//       childAspectRatio: 1,
//     ),
//     itemCount: images.length,
//     itemBuilder: (context, index) {
//       final image = images[index];
//       return Column(
//         children: [
//           Text(
//             image['title'],
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: Image.memory(
//               image['bytes'],
//               fit: BoxFit.cover,
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }

//  @override
// Widget build(BuildContext context) {
//   int _currentIndex = 0;
//   return Scaffold(
//     appBar: AppBar(
//        title: const Text(
//         'Flood Area Detection',
//         style: TextStyle(color: Colors.black),
//       ),
//       leading: IconButton(
//         icon: const Icon(
//           Icons.arrow_back,
//           color: Colors.black,
//         ),
//         onPressed: () {
//           Navigator.of(context).pop();
//         },
//       ),
//       backgroundColor: Colors.white,
//     ),
//     body: Stack(
//       children: [
//         SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const Text(
//                   "Upload an image to detect flood risks.",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _uploadImage,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple[400],
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 15, horizontal: 30),
//                     ),
//                     child: const Text("Upload Image", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _detectFlood,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple[400],
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 15, horizontal: 30),
//                     ),
//                     child: const Text("Detect Flood", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 if (_isLoading)
//                   const Center(child: CircularProgressIndicator()),
//                 if (!_isLoading &&
//                     (_selectedImageBytes != null ||
//                         _groundTruthBytes != null ||
//                         _predictedMaskBytes != null ||
//                         _resultImageBytes != null))
//                   _buildImageGrid(),
//               ],
//             ),
//           ),
//         ),
//         if (_selectedImageBytes != null)
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _clearImage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.purple[400],
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
//                 ),
//                 child: const Text("Clear Image", style: TextStyle(color: Colors.white), ),
//               ),
//             ),
//           ),
//       ],
//     ),
//   );
// }
// }

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
        Uri.parse(
            "https://30d5-2401-4900-6768-5dea-1400-950b-1424-93db.ngrok-free.app/detect"),
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
      if (_groundTruthBytes != null)
        {'title': 'Ground Truth Image', 'bytes': _groundTruthBytes},
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
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return Column(
          children: [
            Text(
              image['title'],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Image.memory(
                image['bytes'],
                fit: BoxFit.cover,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flood Area Detection',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Upload an image to detect flood risks.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _uploadImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                      ),
                      child: const Text("Upload Image",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _detectFlood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                      ),
                      child: const Text("Detect Flood",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (!_isLoading &&
                      (_selectedImageBytes != null ||
                          _groundTruthBytes != null ||
                          _predictedMaskBytes != null ||
                          _resultImageBytes != null))
                    _buildImageGrid(),
                ],
              ),
            ),
          ),
          if (_selectedImageBytes != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _clearImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 207, 47, 36),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                  ),
                  child: const Text(
                    "Clear Image",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
