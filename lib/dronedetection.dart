import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DroneDetectionScreen extends StatefulWidget {
  const DroneDetectionScreen({Key? key}) : super(key: key);

  @override
  _DroneDetectionScreenState createState() => _DroneDetectionScreenState();
}

class _DroneDetectionScreenState extends State<DroneDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> droneImages = [];
  bool isAnalyzing = false;

  Future<void> _uploadDroneImage() async {
    setState(() {
      isAnalyzing = true;
    });

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Simulate processing with a delay
      await Future.delayed(Duration(seconds: 3));
      
      // In a real app, you would send the image to your ML model here
      Map<String, dynamic> result = _mockDroneAnalysisResult();
      
      setState(() {
        droneImages.add({
          'image': image.path,
          'status': result['status'],
          'affectedArea': result['affectedArea'],
          'diseaseSpots': result['diseaseSpots'],
          'color': result['color'],
          'recommendation': result['recommendation'],
          'date': DateTime.now(),
        });
        isAnalyzing = false;
      });
    } else {
      setState(() {
        isAnalyzing = false;
      });
    }
  }

  // Mock function to generate drone analysis results
  Map<String, dynamic> _mockDroneAnalysisResult() {
    final results = [
      {
        'status': 'Disease Detected',
        'affectedArea': '18.3%',
        'diseaseSpots': '24 spots',
        'color': Color(0xFFEF5350),
        'recommendation': 'Focus treatment on the northeast quadrant of your field. Early signs of fungal infection detected.'
      },
      {
        'status': 'Minor Issues',
        'affectedArea': '7.2%',
        'diseaseSpots': '9 spots',
        'color': Color(0xFFFFB74D),
        'recommendation': 'Small clusters of bacterial spot detected in the southern section. Consider targeted fungicide application.'
      },
      {
        'status': 'Healthy',
        'affectedArea': '0.8%',
        'diseaseSpots': '2 spots',
        'color': Color(0xFF66BB6A),
        'recommendation': 'Field looks healthy with minimal issues. Continue regular maintenance and monitoring.'
      },
      {
        'status': 'Water Stress',
        'affectedArea': '12.4%',
        'diseaseSpots': '0 spots',
        'color': Color(0xFF42A5F5),
        'recommendation': 'Western portion shows signs of water stress. Consider adjusting irrigation schedule.'
      },
    ];
    
    return results[DateTime.now().millisecond % results.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Drone Detection',
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
            // Top info section
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
                    'Analyze Drone Imagery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload aerial images from your drone to scan for field-wide disease patterns',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8F9BB3),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: isAnalyzing ? null : _uploadDroneImage,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF2196F3).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.upload_file, color: Color(0xFF2196F3), size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Upload Drone Image',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing aerial imagery...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2E3A59),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'This may take a minute',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8F9BB3),
                      ),
                    ),
                  ],
                ),
              ),
              
            // Drone analysis results
            Expanded(
              child: droneImages.isEmpty && !isAnalyzing
                ? _buildEmptyState()
                : _buildAnalysisResults(),
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
            Icons.flight_outlined,
            size: 80,
            color: Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16),
          Text(
            'No Drone Images Analyzed',
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
              'Upload aerial imagery from your drone to detect field-wide disease patterns',
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

  Widget _buildAnalysisResults() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: droneImages.length,
      itemBuilder: (context, index) {
        final analysis = droneImages[index];
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
              // Drone image with overlay for status
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.file(
                      File(analysis['image']),
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
                        color: analysis['color'],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        analysis['status'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Add a date tag
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${analysis['date'].day}/${analysis['date'].month}/${analysis['date'].year}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Analysis details
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field health metrics
                    Row(
                      children: [
                        _buildMetricBox(
                          label: 'Affected Area',
                          value: analysis['affectedArea'],
                          color: analysis['color'],
                        ),
                        SizedBox(width: 12),
                        _buildMetricBox(
                          label: 'Disease Spots',
                          value: analysis['diseaseSpots'],
                          color: analysis['color'],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Recommendation
                    Text(
                      'AI Recommendation:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8F9BB3),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      analysis['recommendation'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // View detailed report
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2196F3),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('View Detailed Map'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Share analysis
                            },
                            icon: Icon(Icons.share, color: Color(0xFF2E3A59)),
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

  Widget _buildMetricBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8F9BB3),
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}