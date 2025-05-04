import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrosensor/services/sensor.dart';

class SimpleSoilAnalysisScreen extends StatefulWidget {
  const SimpleSoilAnalysisScreen({Key? key}) : super(key: key);

  @override
  _SimpleSoilAnalysisScreenState createState() => _SimpleSoilAnalysisScreenState();
}

class _SimpleSoilAnalysisScreenState extends State<SimpleSoilAnalysisScreen> {
  bool showDetails = false;
  final TextEditingController _codeController = TextEditingController();
  String _currentTableCode = '';
  bool _isCodeValid = false;
  bool _isConnecting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final tableCode = _codeController.text.trim();
    if (tableCode.isEmpty || tableCode.length < 4) {
      setState(() {
        _isCodeValid = false;
      });
      _showSnackBar('Sensor ID must be at least 4 characters', false);
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final sensor = Provider.of<SensorProvider>(context, listen: false);
      await sensor.connectToTable(tableCode);
      
      setState(() {
        _currentTableCode = tableCode;
        _isCodeValid = true;
      });
      
      _showSnackBar('Connected to Senser ID: $tableCode', true);
    } catch (e) {
      setState(() {
        _isCodeValid = false;
      });
      _showSnackBar('Connection failed: ${e.toString()}', false);
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Color(0xFF4CAF50) : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensor = Provider.of<SensorProvider>(context);
    
    // Debug prints to monitor state changes
    debugPrint('Building with sensor data:');
    debugPrint('  Connected: ${sensor.isConnected}');
    debugPrint('  Table: ${sensor.currentTableName}');
    debugPrint('  Temp: ${sensor.temperature}°C');
    debugPrint('  Moisture: ${sensor.moisture}%');
    debugPrint('  pH: ${sensor.ph}');
    debugPrint('  EC: ${sensor.ec} μS');
    debugPrint('  Salinity: ${sensor.salinity} mg/L');
    debugPrint('  Last updated: ${sensor.lastUpdated}');
    debugPrint('  Loading: ${sensor.isLoading}');
    debugPrint('  Error: ${sensor.errorMessage}');

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
          // if (sensor.isConnected)
          //   IconButton(
          //     icon: Icon(Icons.refresh),
          //     onPressed: () => sensor.refreshData(),
          //   ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTableCodeInput(sensor),
              SizedBox(height: 16),
              if (sensor.errorMessage.isNotEmpty)
                _buildErrorCard(sensor),
              if (sensor.isConnected) ...[
                _buildSoilHealthCard(sensor),
                SizedBox(height: 24),
                _buildParamSection(sensor),
                SizedBox(height: 24),
                _buildSoilStatusCard(sensor),
                SizedBox(height: 24),
                _buildRecommendationCard(sensor),
              ] else if (_isConnecting) ...[
                Center(child: CircularProgressIndicator()),
              ] else ...[
                _buildConnectionPrompt(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(SensorProvider sensor) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              sensor.errorMessage,
              style: TextStyle(color: Colors.red[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCodeInput(SensorProvider sensor) {
    return Container(
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
            children: [
              Icon(Icons.qr_code, color: Color(0xFF3F51B5), size: 20),
              SizedBox(width: 8),
              Text(
                'Sensor ID Connection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3A59),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    hintText: 'Enter your Sensor ID',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFE4E9F2)),
                    ),
                    suffixIcon: _codeController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _codeController.clear();
                                _isCodeValid = false;
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(width: 8),
              _isConnecting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _validateCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3F51B5),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Connect'),
                    ),
            ],
          ),
          SizedBox(height: 8),
          if (sensor.isConnected) ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Connected to: ${sensor.currentTableName}',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          Text(
            'Enter your sensor ID to view its data',
            style: TextStyle(fontSize: 12, color: Color(0xFF8F9BB3)),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPrompt() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.sensors, size: 48, color: Colors.blueGrey[300]),
          SizedBox(height: 16),
          Text(
            'Connect to a Sensor ID',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enter your sensor ID above to view real-time soil analysis data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8F9BB3),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSoilHealthCard(SensorProvider sensor) {
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
            'Last updated: ${sensor.lastUpdated}',
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
    final parameters = [
      {
        'name': 'Temperature',
        'value': sensor.temperature,
        'unit': '°C',
        'min': 18.0,  // Optimal range for lettuce
        'max': 25.0,
        'icon': Icons.thermostat_outlined,
        'color': Color(0xFFFF8A65),
        'description': 'Ideal for most crops. Below 18°C slows growth, above 25°C may cause bolting.'
      },
      {
        'name': 'Moisture',
        'value': sensor.moisture,
        'unit': '%',
        'min': 60.0,  // Optimal range for lettuce
        'max': 80.0,
        'icon': Icons.water_drop_outlined,
        'color': Color(0xFF4FC3F7),
        'description': 'Maintain consistent moisture. Too dry causes wilting, too wet promotes disease.'
      },
      {
        'name': 'pH',
        'value': sensor.ph,
        'unit': '',
        'min': 6.0,  // Optimal range for lettuce
        'max': 6.5,
        'icon': Icons.science_outlined,
        'color': Color(0xFF9575CD),
        'description': 'Slightly acidic is ideal. Below 6.0 reduces nutrient availability.'
      },
      {
        'name': 'Salinity',
        'value': sensor.salinity.toDouble(),
        'unit': 'mg/L',
        'min': 500.0,  // Based on your data
        'max': 1000.0,
        'icon': Icons.grain,
        'color': Color(0xFF4DB6AC),
        'description': 'Moderate salinity is acceptable. High levels can damage roots.'
      },
      {
        'name': 'EC',
        'value': sensor.ec.toDouble(),
        'unit': 'μS',
        'min': 500.0,  // Based on your data
        'max': 1200.0,
        'icon': Icons.bolt_outlined,
        'color': Color(0xFFFFD54F),
        'description': 'Indicates nutrient levels. Too low means deficiency, too high may burn plants.'
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
            bool isOptimal = param['value'] != null && 
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
                            '${(param['value'] as double).toStringAsFixed(1)}${param['unit']}',
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
                            '${param['min']}-${param['max']}${param['unit']}',
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
    // Weighted average calculation based on importance
    double tempScore = _calculateParameterScore(sensor.temperature, 18.0, 25.0);
    double moistureScore = _calculateParameterScore(sensor.moisture, 60.0, 80.0);
    double phScore = _calculateParameterScore(sensor.ph, 6.0, 6.5);
    double salinityScore = _calculateParameterScore(sensor.salinity.toDouble(), 500.0, 1000.0);
    double ecScore = _calculateParameterScore(sensor.ec.toDouble(), 500.0, 1200.0);
    
    return (tempScore * 0.2 + 
            moistureScore * 0.3 + 
            phScore * 0.25 + 
            salinityScore * 0.15 + 
            ecScore * 0.1);
  }
  
  double _calculateParameterScore(double value, double min, double max) {
    if (value >= min && value <= max) return 100.0;
    if (value < min) {
      double deficit = min - value;
      double percentBelow = (deficit / min) * 100;
      return (100 - percentBelow).clamp(0, 100);
    } else {
      double excess = value - max;
      double percentAbove = (excess / max) * 100;
      return (100 - percentAbove).clamp(0, 100);
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
      return "Your soil is in excellent condition for growing crops. All parameters are within optimal ranges.";
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
    
    // Temperature recommendations (18-25°C range)
    if (sensor.temperature < 18.0) {
      recommendations.add({
        'title': 'Increase Soil Temperature',
        'description': 'Use black plastic mulch or row covers to warm soil. Consider planting in warmer seasons.',
        'icon': Icons.thermostat_outlined,
        'color': Color(0xFFFF8A65),
      });
    } else if (sensor.temperature > 25.0) {
      recommendations.add({
        'title': 'Reduce Soil Temperature',
        'description': 'Apply light-colored mulch or provide shade cloth to cool soil during hot periods.',
        'icon': Icons.thermostat_outlined,
        'color': Color(0xFFFF8A65),
      });
    }
    
    // Moisture recommendations (60-80% range)
    if (sensor.moisture < 60.0) {
      recommendations.add({
        'title': 'Increase Soil Moisture',
        'description': 'Water deeply and regularly. Use drip irrigation and organic mulch to retain moisture.',
        'icon': Icons.water_drop_outlined,
        'color': Color(0xFF4FC3F7),
      });
    } else if (sensor.moisture > 80.0) {
      recommendations.add({
        'title': 'Improve Drainage',
        'description': 'Add organic matter or create raised beds to improve drainage and prevent waterlogging.',
        'icon': Icons.water_drop_outlined,
        'color': Color(0xFF4FC3F7),
      });
    }
    
    // pH recommendations (6.0-6.5 range)
    if (sensor.ph < 6.0) {
      recommendations.add({
        'title': 'Increase Soil pH',
        'description': 'Apply agricultural lime at recommended rates to raise pH. Retest after 2-3 weeks.',
        'icon': Icons.science_outlined,
        'color': Color(0xFF9575CD),
      });
    } else if (sensor.ph > 6.5) {
      recommendations.add({
        'title': 'Lower Soil pH',
        'description': 'Apply elemental sulfur or organic matter like peat moss to gradually lower pH.',
        'icon': Icons.science_outlined,
        'color': Color(0xFF9575CD),
      });
    }
    
    // Salinity recommendations (500-1000 mg/L range)
    if (sensor.salinity > 1000) {
      recommendations.add({
        'title': 'Reduce Soil Salinity',
        'description': 'Leach soil with clean water and improve drainage. Avoid over-fertilizing.',
        'icon': Icons.grain,
        'color': Color(0xFF4DB6AC),
      });
    }
    
    // EC recommendations (500-1200 μS range)
    if (sensor.ec < 500) {
      recommendations.add({
        'title': 'Increase Nutrients',
        'description': 'Apply balanced fertilizer according to soil test recommendations.',
        'icon': Icons.bolt_outlined,
        'color': Color(0xFFFFD54F),
      });
    } else if (sensor.ec > 1200) {
      recommendations.add({
        'title': 'Reduce Nutrient Levels',
        'description': 'Flush soil with clean water and reduce fertilizer applications.',
        'icon': Icons.bolt_outlined,
        'color': Color(0xFFFFD54F),
      });
    }
    
    // Default recommendation if all parameters are optimal
    if (recommendations.isEmpty) {
      recommendations.add({
        'title': 'Maintain Current Practices',
        'description': 'Your soil conditions are optimal. Continue regular monitoring and maintenance.',
        'icon': Icons.check_circle,
        'color': Color(0xFF4CAF50),
      });
    }
    
    return recommendations;
  }
}