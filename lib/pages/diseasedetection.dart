import 'package:flutter/material.dart';
import 'package:agrosensor/pages/quickdetection.dart';
//import 'package:agrosensor/dronedetection.dart';

class DiseaseDetectionScreen extends StatelessWidget {
  const DiseaseDetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Disease Detection',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 30),
              _buildDetectionOptions(context),
              SizedBox(height: 30),
              //_buildRecentDetections(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detect Diseases in Lettuce',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E3A59),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Choose a detection method to identify and diagnose lettuce diseases quickly and accurately.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF8F9BB3),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionOptions(BuildContext context) {
    return Column(
      children: [
        // Quick Detection Card
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuickDetectionScreen()),
            );
          },
          child: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF4CAF50),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Detection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E3A59),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Take a photo of the plant leaf to instantly detect diseases',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8F9BB3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF8F9BB3),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Drone Detection Card
        // GestureDetector(
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => DroneDetectionScreen()),
        //     );
        //   },
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(16),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(0.05),
        //           offset: Offset(0, 4),
        //           blurRadius: 10,
        //         ),
        //       ],
        //     ),
        //     child: Padding(
        //       padding: const EdgeInsets.all(20.0),
        //       child: Row(
        //         children: [
        //           Container(
        //             padding: EdgeInsets.all(16),
        //             decoration: BoxDecoration(
        //               color: Color(0xFF2196F3).withOpacity(0.1),
        //               borderRadius: BorderRadius.circular(16),
        //             ),
        //             child: Icon(
        //               Icons.flight_outlined,
        //               color: Color(0xFF2196F3),
        //               size: 32,
        //             ),
        //           ),
        //           SizedBox(width: 20),
        //           Expanded(
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text(
        //                   'Drone Detection',
        //                   style: TextStyle(
        //                     fontSize: 18,
        //                     fontWeight: FontWeight.w600,
        //                     color: Color(0xFF2E3A59),
        //                   ),
        //                 ),
        //                 SizedBox(height: 5),
        //                 Text(
        //                   'Analyze aerial imagery from drones to detect field-wide issues',
        //                   style: TextStyle(
        //                     fontSize: 14,
        //                     color: Color(0xFF8F9BB3),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           Icon(
        //             Icons.arrow_forward_ios,
        //             color: Color(0xFF8F9BB3),
        //             size: 18,
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}