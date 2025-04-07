import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class QuickDetectionScreen extends StatefulWidget {
  const QuickDetectionScreen({Key? key}) : super(key: key);

  @override
  _QuickDetectionScreenState createState() => _QuickDetectionScreenState();
}

class _QuickDetectionScreenState extends State<QuickDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> detectedImages = [];
  bool isAnalyzing = false;

  Future<void> _takePhoto() async {
    setState(() {
      isAnalyzing = true;
    });

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    
    if (photo != null) {
      // Simulate disease detection with a delay
      await Future.delayed(Duration(seconds: 2));
      
      // In a real app, you would send the image to your ML model here
      // For now, we'll use mock results
      Map<String, dynamic> result = _mockDetectionResult();
      
      setState(() {
        detectedImages.add({
          'image': photo.path,
          'disease': result['disease'],
          'confidence': result['confidence'],
          'color': result['color'],
          'treatment': result['treatment'],
        });
        isAnalyzing = false;
      });
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

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Simulate disease detection with a delay
      await Future.delayed(Duration(seconds: 2));
      
      // In a real app, you would send the image to your ML model here
      Map<String, dynamic> result = _mockDetectionResult();
      
      setState(() {
        detectedImages.add({
          'image': image.path,
          'disease': result['disease'],
          'confidence': result['confidence'],
          'color': result['color'],
          'treatment': result['treatment'],
        });
        isAnalyzing = false;
      });
    } else {
      setState(() {
        isAnalyzing = false;
      });
    }
  }

  // Mock function to generate random detection results
  Map<String, dynamic> _mockDetectionResult() {
    final diseases = [
      {
        'disease': 'Early Blight',
        'confidence': '96.2%',
        'color': Color(0xFFEF5350),
        'treatment': 'Apply copper-based fungicide and improve air circulation.'
      },
      {
        'disease': 'Bacterial Spot',
        'confidence': '89.5%',
        'color': Color(0xFFFFB74D),
        'treatment': 'Use copper fungicides and avoid overhead irrigation.'
      },
      {
        'disease': 'Powdery Mildew',
        'confidence': '94.1%',
        'color': Color(0xFF9575CD),
        'treatment': 'Apply sulfur-based fungicide and increase spacing between plants.'
      },
      {
        'disease': 'Healthy',
        'confidence': '98.3%',
        'color': Color(0xFF66BB6A),
        'treatment': 'No treatment needed. Continue regular care.'
      },
    ];
    
    return diseases[DateTime.now().millisecond % diseases.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Quick Disease Detection',
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
                    'Make sure the leaf is well-lit and centered in the frame',
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
                      // _buildActionButton(
                      //   title: 'From Gallery',
                      //   icon: Icons.photo_library_outlined,
                      //   color: Color(0xFF2196F3),
                      //   onTap: isAnalyzing ? null : _pickFromGallery,
                      // ),
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
              // Image with overlay for disease status
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
                            detection['confidence'],
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
                              // View detailed report
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