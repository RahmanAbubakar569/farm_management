import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrosensor/sensor.dart';
import 'dart:math';
class SimpleSoilAnalysisScreen extends StatefulWidget {
  const SimpleSoilAnalysisScreen({Key? key}) : super(key: key);

  @override
  _SimpleSoilAnalysisScreenState createState() => _SimpleSoilAnalysisScreenState();
}

class _SimpleSoilAnalysisScreenState extends State<SimpleSoilAnalysisScreen> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    final sensor = Provider.of<SensorProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Soil Analysis',
          style: TextStyle(
            color: Color(0xFF2E3A59),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF2E3A59),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              setState(() {
                showDetails = !showDetails;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSoilHealthCard(sensor),
              SizedBox(height: 24),
              _buildParamSection(sensor),
              SizedBox(height: 24),
              _buildSoilStatusCard(sensor),
              SizedBox(height: 24),
              _buildRecommendationCard(sensor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoilHealthCard(SensorProvider sensor) {
    // Evaluate overall soil health based on all parameters
    double soilHealthScore = _calculateSoilHealth(sensor);
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.3),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soil Health',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  soilHealthScore >= 85 ? 'Excellent' : 
                  soilHealthScore >= 70 ? 'Good' : 
                  soilHealthScore >= 50 ? 'Average' : 'Poor',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Use ClipRect and align the container instead of setting width directly
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: soilHealthScore / 100,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Text(
                '${soilHealthScore.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Last updated: Now',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamSection(SensorProvider sensor) {
    // Define parameters with current, optimal min and max values
    final parameters = [
      {
        'name': 'Temperature',
        'value': sensor.temperature,
        'unit': '°C',
        'min': 15.0,
        'max': 20.0,
        'icon': Icons.thermostat_outlined,
        'color': Color(0xFFFF8A65),
        'description': 'Soil temperature affects microbial activity and nutrient availability.'
      },
      {
        'name': 'Moisture',
        'value': sensor.moisture,
        'unit': '%',
        'min': 70.0,
        'max': 80.0,
        'icon': Icons.water_drop_outlined,
        'color': Color(0xFF4FC3F7),
        'description': 'Adequate moisture is essential for nutrient transport and uptake.'
      },
      {
        'name': 'pH',
        'value': sensor.ph,
        'unit': '',
        'min': 6.0,
        'max': 6.5,
        'icon': Icons.science_outlined,
        'color': Color(0xFF9575CD),
        'description': 'pH affects nutrient availability, with most vegetables preferring slightly acidic soil.'
      },
      {
        'name': 'Salinity',
        'value': sensor.salinity,
        'unit': 'mg/L',
        'min': 500.0,
        'max': 950.0,
        'icon': Icons.grain,
        'color': Color(0xFF4DB6AC),
        'description': 'High salinity can harm plants by reducing water uptake and causing ion toxicity.'
      },
      {
        'name': 'EC',
        'value': sensor.ec,
        'unit': 'μS',
        'min': 800.0,
        'max': 1500.0,
        'icon': Icons.bolt_outlined,
        'color': Color(0xFFFFD54F),
        'description': 'Electrical conductivity indicates the level of dissolved nutrients.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Parameters',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3A59),
          ),
        ),
        SizedBox(height: 16),
        Column(
          children: parameters.map((param) {
            bool isOptimal = param['value'] != null && param['min'] != null && param['max'] != null &&
                (param['value'] as num) >= (param['min'] as num) && 
                (param['value'] as num) <= (param['max'] as num);
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (param['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                param['icon'] as IconData,
                                color: param['color'] as Color,
                                size: 18,
                              ),
                            ),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                param['name'] as String,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E3A59),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOptimal ? Color(0xFF4CAF50).withOpacity(0.1) : Color(0xFFFF5722).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOptimal ? 'Optimal' : 'Needs Attention',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isOptimal ? Color(0xFF4CAF50) : Color(0xFFFF5722),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Current: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8F9BB3),
                            ),
                          ),
                          Text(
                            '${(param['value'] is int ? (param['value'] as int).toDouble() : param['value'] as double).toStringAsFixed(1)} ${param['unit']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E3A59),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Optimal: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8F9BB3),
                            ),
                          ),
                          Text(
                            '${param['min']}-${param['max']} ${param['unit']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E3A59),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (showDetails) ...[
                    SizedBox(height: 12),
                    Text(
                      param['description'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8F9BB3),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSoilStatusCard(SensorProvider sensor) {
    String soilStatus = _getSoilStatus(sensor);
    String statusDescription = _getSoilStatusDescription(sensor);
    IconData statusIcon = _getSoilStatusIcon(sensor);
    Color statusColor = _getSoilStatusColor(sensor);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soil Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      soilStatus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      statusDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8F9BB3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(SensorProvider sensor) {
    List<Map<String, dynamic>> recommendations = _getRecommendations(sensor);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3A59),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Column(
            children: recommendations.map((rec) {
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (rec['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        rec['icon'] as IconData,
                        color: rec['color'] as Color,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E3A59),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            rec['description'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8F9BB3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Helper functions to evaluate soil conditions
  
  double _calculateSoilHealth(SensorProvider sensor) {
    // Calculate soil health score based on parameter proximity to optimal ranges
    double tempScore = _calculateParameterScore(sensor.temperature, 15.0, 20.0);
    double moistureScore = _calculateParameterScore(sensor.moisture, 70.0, 80.0);
    double phScore = _calculateParameterScore(sensor.ph, 6.0, 6.5);
    double salinityScore = _calculateParameterScore(sensor.salinity is int ? 
                                              (sensor.salinity as int).toDouble() : 
                                              sensor.salinity as double, 500.0, 950.0);
    double ecScore = _calculateParameterScore(
      sensor.ec is int ? (sensor.ec as int).toDouble() : (sensor.ec as double),
      800.0, 
      1500.0
    );
    
    // Weighted average (can adjust weights based on importance)
    return (tempScore * 0.15 + moistureScore * 0.3 + phScore * 0.25 + 
            salinityScore * 0.15 + ecScore * 0.15);
  }
  
  double _calculateParameterScore(double value, double min, double max) {
    if (value >= min && value <= max) {
      return 100.0; // Optimal range
    } else if (value < min) {
      // Calculate percentage below min (decreasing as it gets further from min)
      double deficit = min - value;
      double percentBelow = (deficit / min) * 100;
      return (100 - percentBelow) < 0 ? 0 : (100 - percentBelow); // Ensure score doesn't go below 0
    } else { // value > max
      // Calculate percentage above max (decreasing as it gets further from max)
      double excess = value - max;
      double percentAbove = (excess / max) * 100;
      return percentAbove > 100 ? 0 : 100 - percentAbove; // Ensure score doesn't go below 0
    }
  }
  
  String _getSoilStatus(SensorProvider sensor) {
    double healthScore = _calculateSoilHealth(sensor);
    
    if (healthScore >= 85) return "Excellent";
    if (healthScore >= 70) return "Good";
    if (healthScore >= 50) return "Fair";
    return "Poor";
  }
  
  String _getSoilStatusDescription(SensorProvider sensor) {
    double healthScore = _calculateSoilHealth(sensor);
    
    if (healthScore >= 85) {
      return "Your soil is in excellent condition for growing lettuce. All parameters are within optimal ranges.";
    } else if (healthScore >= 70) {
      return "Your soil is in good condition with minor adjustments needed for optimal growth.";
    } else if (healthScore >= 50) {
      return "Your soil requires attention in several areas to improve crop health and yield.";
    } else {
      return "Your soil needs significant improvement across multiple parameters for healthy crop growth.";
    }
  }
  
  IconData _getSoilStatusIcon(SensorProvider sensor) {
    double healthScore = _calculateSoilHealth(sensor);
    
    if (healthScore >= 85) return Icons.check_circle;
    if (healthScore >= 70) return Icons.thumb_up;
    if (healthScore >= 50) return Icons.warning;
    return Icons.error;
  }
  
  Color _getSoilStatusColor(SensorProvider sensor) {
    double healthScore = _calculateSoilHealth(sensor);
    
    if (healthScore >= 85) return Color(0xFF4CAF50);
    if (healthScore >= 70) return Color(0xFF8BC34A);
    if (healthScore >= 50) return Color(0xFFFFB74D);
    return Color(0xFFEF5350);
  }
  
  List<Map<String, dynamic>> _getRecommendations(SensorProvider sensor) {
    List<Map<String, dynamic>> recommendations = [];
    
    // Temperature recommendations
    if (sensor.temperature < 18.0) {
      recommendations.add({
        'title': 'Increase Soil Temperature',
        'description': 'Consider using black plastic mulch to increase soil temperature, or plant during warmer seasons.',
        'icon': Icons.thermostat_outlined,
        'color': Color(0xFFFF8A65),
      });
    } else if (sensor.temperature > 25.0) {
      recommendations.add({
        'title': 'Reduce Soil Temperature',
        'description': 'Apply organic mulch to cool soil temperature, increase shade, or water during cooler parts of the day.',
        'icon': Icons.thermostat_outlined,
        'color': Color(0xFFFF8A65),
      });
    }
    
    // Moisture recommendations
    if (sensor.moisture < 60.0) {
      recommendations.add({
        'title': 'Increase Soil Moisture',
        'description': 'Implement regular irrigation schedule. Consider drip irrigation and organic mulch to retain moisture.',
        'icon': Icons.water_drop_outlined,
        'color': Color(0xFF4FC3F7),
      });
    } else if (sensor.moisture > 80.0) {
      recommendations.add({
        'title': 'Reduce Soil Moisture',
        'description': 'Improve drainage by adding organic matter, reducing irrigation, or creating raised beds for better water flow.',
        'icon': Icons.water_drop_outlined,
        'color': Color(0xFF4FC3F7),
      });
    }
    
    // pH recommendations
    if (sensor.ph < 5.5) {
      recommendations.add({
        'title': 'Increase Soil pH',
        'description': 'Add agricultural lime or wood ash to raise pH. Retest after 2-3 weeks to check progress.',
        'icon': Icons.science_outlined,
        'color': Color(0xFF9575CD),
      });
    } else if (sensor.ph > 6.5) {
      recommendations.add({
        'title': 'Reduce Soil pH',
        'description': 'Add sulfur, iron sulfate, or organic matter like pine needles or peat moss to lower pH. Retest after application.',
        'icon': Icons.science_outlined,
        'color': Color(0xFF9575CD),
      });
    }
    
    // Salinity recommendations
    if (sensor.salinity > 2.0) {
      recommendations.add({
        'title': 'Reduce Soil Salinity',
        'description': 'Leach the soil with quality irrigation water, improve drainage, and incorporate organic matter to reduce salinity.',
        'icon': Icons.grain,
        'color': Color(0xFF4DB6AC),
      });
    }
    
    // EC recommendations
    if (sensor.ec < 0.5) {
      recommendations.add({
        'title': 'Increase Nutrient Availability',
        'description': 'Apply balanced organic fertilizer or compost to increase nutrient levels. Consider foliar feeding for quick uptake.',
        'icon': Icons.bolt_outlined,
        'color': Color(0xFFFFD54F),
      });
    } else if (sensor.ec > 1.5) {
      recommendations.add({
        'title': 'Reduce Nutrient Concentration',
        'description': 'Flush soil with clean water to reduce EC levels. Avoid over-fertilization and monitor carefully.',
        'icon': Icons.bolt_outlined,
        'color': Color(0xFFFFD54F),
      });
    }
    
    // If no specific recommendations, add general improvement tip
    if (recommendations.isEmpty) {
      recommendations.add({
        'title': 'Maintain Optimal Soil Conditions',
        'description': 'Continue your current soil management practices. Regular monitoring and organic matter additions will help maintain soil health.',
        'icon': Icons.check_circle,
        'color': Color(0xFF4CAF50),
      });
    }
    
    return recommendations;
  }
}