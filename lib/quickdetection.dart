import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class QuickDetectionScreen extends StatefulWidget {
  const QuickDetectionScreen({Key? key}) : super(key: key);

  @override
  _QuickDetectionScreenState createState() => _QuickDetectionScreenState();
}

class _QuickDetectionScreenState extends State<QuickDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> detectedImages = [];
  bool isAnalyzing = false;
  
  // Update this with your Raspberry Pi's IP address and port
  final String serverUrl = 'http://10.42.0.1:8080';

  Future<void> _takePhoto() async {
    setState(() {
      isAnalyzing = true;
    });

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      // Better quality settings for plant disease analysis
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 95,
    );
    
    if (photo != null) {
      _processImage(photo);
    } else {
      setState(() {
        isAnalyzing = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      isAnalyzing = true;
    });

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 95,
    );
    
    if (image != null) {
      _processImage(image);
    } else {
      setState(() {
        isAnalyzing = false;
      });
    }
  }

  Future<void> _processImage(XFile imageFile) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$serverUrl/predict'));
      
      // Add file to request
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Map<String, dynamic> predictionResult = json.decode(response.body);
        
        // Get disease class from prediction result
        String diseaseClass = predictionResult['predicted_class'];
        
        // Get treatment and color based on detected class
        Map<String, dynamic> displayData = _getDisplayDataForClass(diseaseClass);
        
        setState(() {
          detectedImages.add({
            'image': imageFile.path,
            'disease': diseaseClass,
            'color': displayData['color'],
            'treatment': displayData['treatment'],
          });
          isAnalyzing = false;
        });
      } else {
        // Handle error
        setState(() {
          isAnalyzing = false;
        });
        _showErrorDialog('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isAnalyzing = false;
      });
      _showErrorDialog('Connection error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Get display data based on disease class
  Map<String, dynamic> _getDisplayDataForClass(String diseaseClass) {
    switch (diseaseClass) {
      case 'Bacterial':
        return {
          'color': Color(0xFFEF5350),
          'treatment': 'Apply copper-based bactericides. Remove and destroy infected plant parts. Avoid overhead irrigation. Keep the area around plants clean and free of debris. Use disease-free seeds and transplants.'
        };
      case 'Fungal':
        return {
          'color': Color(0xFFFFB74D),
          'treatment': 'Apply appropriate fungicide. Improve air circulation by properly spacing plants. Remove infected plant material immediately. Water at the base of plants to keep foliage dry. Rotate crops annually to prevent buildup of fungi in soil.'
        };
      case 'Healthy':
        return {
          'color': Color(0xFF66BB6A),
          'treatment': 'No treatment needed. Continue regular care and monitoring. Maintain consistent watering schedule. Apply balanced fertilizer according to plant needs. Keep observing for early signs of issues.'
        };
      default:
        return {
          'color': Color(0xFF9575CD),
          'treatment': 'Consult with a plant specialist for proper diagnosis and treatment. Take multiple photos from different angles for better assessment.'
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Plant Disease Detection',
          style: TextStyle(
            color: Color(0xFF2E3A59),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2E3A59)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top action area with camera and gallery buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Take a clear photo of the plant leaf',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ensure good lighting and focus on the affected area',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8F9BB3),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        title: 'Take Photo',
                        icon: Icons.camera_alt_outlined,
                        color: Color(0xFF4CAF50),
                        onTap: isAnalyzing ? null : _takePhoto,
                      ),
                      _buildActionButton(
                        title: 'From Gallery',
                        icon: Icons.photo_library_outlined,
                        color: Color(0xFF2196F3),
                        onTap: isAnalyzing ? null : _pickFromGallery,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status indicator during analysis
            if (isAnalyzing)
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing leaf image...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2E3A59),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
            // Detection results
            Expanded(
              child: detectedImages.isEmpty && !isAnalyzing
                ? _buildEmptyState()
                : _buildDetectionResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16),
          Text(
            'No Images Analyzed Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Take a photo or select an image from your gallery to detect diseases',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8F9BB3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionResults() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: detectedImages.length,
      itemBuilder: (context, index) {
        final detection = detectedImages[index];
        return Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with disease status
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.file(
                      File(detection['image']),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: detection['color'],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            detection['disease'] == 'Healthy' 
                                ? Icons.check_circle
                                : Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            detection['disease'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Detection results
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: detection['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            detection['disease'] == 'Healthy' 
                                ? Icons.check_circle_outline
                                : Icons.bug_report_outlined,
                            color: detection['color'],
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          detection['disease'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E3A59),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    Text(
                      'Recommended Treatment:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8F9BB3),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      detection['treatment'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // View detailed report functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('View Detailed Report'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}