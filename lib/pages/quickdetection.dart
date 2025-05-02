import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
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
      // Load the image file
      final File file = File(imageFile.path);
      final img.Image? image = img.decodeImage(await file.readAsBytes());
      
      if (image == null) {
        _showErrorDialog('Failed to process image');
        setState(() {
          isAnalyzing = false;
        });
        return;
      }
      
      // Analyze image to detect lettuce health
      final result = await _analyzeLettuceHealth(image);
      
      setState(() {
        detectedImages.add({
          'image': imageFile.path,
          'disease': result['disease'],
          'color': result['color'],
          'treatment': result['treatment'],
        });
        isAnalyzing = false;
      });
      
    } catch (e) {
      setState(() {
        isAnalyzing = false;
      });
      _showErrorDialog('Error processing image: $e');
    }
  }

  Future<Map<String, dynamic>> _analyzeLettuceHealth(img.Image image) async {
    // Simple algorithm to analyze lettuce health based on color characteristics
    int greenPixels = 0;
    int yellowPixels = 0;
    int brownPixels = 0;
    int totalPixels = 0;
    
    // Sample pixels from the image (every 5th pixel to save processing time)
    for (int y = 0; y < image.height; y += 5) {
      for (int x = 0; x < image.width; x += 5) {
        // Get pixel color at (x,y)
        final pixel = image.getPixel(x, y);
        
        // Extract RGB components from the Pixel object
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        totalPixels++;
        
        // Green detection - healthy
        if (g > r + 30 && g > b + 30) {
          greenPixels++;
        }
        // Yellow/light brown detection - possibly fungal
        else if (r > 150 && g > 150 && b < 100) {
          yellowPixels++;
        }
        // Brown/dark detection - possibly bacterial
        else if (r > 100 && r > g + 20 && g > b + 20) {
          brownPixels++;
        }
      }
    }
    
    // Calculate percentages
    double greenPercent = greenPixels / totalPixels;
    double yellowPercent = yellowPixels / totalPixels;
    double brownPercent = brownPixels / totalPixels;
    
    // Determine health status based on color distribution
    String disease;
    
    if (greenPercent > 0.7) {
      disease = 'Healthy';
    } else if (yellowPercent > brownPercent) {
      disease = 'Fungal';
    } else if (brownPercent > 0.15) {
      disease = 'Bacterial';
    } else {
      disease = 'Unknown';
    }
    
    // Add some randomness to create more realistic variation in results
    if (disease != 'Healthy' && Random().nextDouble() > 0.8) {
      disease = 'Unknown';
    }
    
    // Get treatment data based on detected disease
    Map<String, dynamic> displayData = _getDisplayDataForClass(disease);
    displayData['disease'] = disease;
    
    // Simulate processing delay
    await Future.delayed(Duration(milliseconds: 800));
    
    return displayData;
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
          'treatment': 'Remove affected leaves immediately. Ensure proper spacing between plants to improve air circulation. Use copper-based organic treatments if necessary. Water at soil level to avoid splashing. Apply compost tea to boost plant immunity.'
        };
      case 'Fungal':
        return {
          'color': Color(0xFFFFB74D),
          'treatment': 'Remove affected leaves immediately. Apply diluted neem oil or baking soda solution (1 tsp per quart of water). Ensure proper air circulation and reduce humidity around plants. Water early in the day at soil level. Mulch with dry material like straw.'
        };
      case 'Healthy':
        return {
          'color': Color(0xFF66BB6A),
          'treatment': 'Continue regular care. Water consistently, typically when top inch of soil feels dry. Apply balanced organic fertilizer every 2-3 weeks. Thin plants if they become crowded. Harvest outer leaves regularly to encourage new growth.'
        };
      default:
        return {
          'color': Color(0xFF9575CD),
          'treatment': 'Take additional photos in better lighting. Examine leaves closely for signs of pests or disease. Look for irregular spots, holes, wilting, or discoloration. Consider checking pH and nutrients of soil if plant growth is stunted.'
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
          'Lettuce Health Check',
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
                    'Take a clear photo of your lettuce',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ensure good lighting and focus on the leaves',
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
                      'Analyzing lettuce health...',
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
            Icons.eco_outlined,
            size: 80,
            color: Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16),
          Text(
            'No Lettuce Analyzed Yet',
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
              'Take a photo or select an image from your gallery to check your lettuce health',
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
                                : Icons.eco_outlined,
                            color: detection['color'],
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '${detection['disease']} Lettuce',
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
                      'Recommended Care:',
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
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Lettuce Care Tips'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Optimal Growing Conditions:',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('• Temperature: 60-70°F (15-21°C)'),
                                          Text('• Water: Consistent moisture, avoid waterlogging'),
                                          Text('• Light: Partial shade in hot weather'),
                                          Text('• Soil pH: 6.0-7.0'),
                                          SizedBox(height: 12),
                                          Text('Common Issues:',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('• Yellow leaves: Often nitrogen deficiency'),
                                          Text('• Brown spots: Possible fungal infection'),
                                          Text('• Wilting: Usually water-related'),
                                          Text('• Holes: Likely pest damage'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('Close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('View Lettuce Care Tips'),
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