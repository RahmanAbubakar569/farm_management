import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:agrosensor/diseasedetection.dart';
import 'package:agrosensor/soil.dart';
import 'package:agrosensor/cropai.dart';
import 'package:agrosensor/sensor.dart';
import 'package:provider/provider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => SensorProvider(),
      child: AgroSenseApp(),
    ),
  );
}

class AgroSenseApp extends StatelessWidget {
  const AgroSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgroSense',
      theme: ThemeData(
        primaryColor: Color(0xFF4CAF50),
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String currentDate = DateFormat('E, d MMM').format(DateTime.now());

  // Sample data for dashboard
  Map<String, dynamic> getSoilParameters(SensorProvider sensor) {
  return {
    'Temperature': {
      'value': sensor.temperature.toStringAsFixed(1),
      'unit': '°C',
      'icon': Icons.thermostat_outlined,
      'color': Color(0xFFFF8A65),
    },
    'Moisture': {
      'value': sensor.moisture.toStringAsFixed(1),
      'unit': '%',
      'icon': Icons.water_drop_outlined,
      'color': Color(0xFF4FC3F7),
    },
    'pH': {
      'value': sensor.ph.toStringAsFixed(1),
      'unit': 'pH',
      'icon': Icons.science_outlined,
      'color': Color(0xFF9575CD),
    },
    'Salinity': {
      'value': sensor.salinity.toStringAsFixed(1),
      'unit': 'mg/L',
      'icon': Icons.grain,
      'color': Color(0xFF4DB6AC),
    },
    'ec': {
      'value': sensor.ec.toStringAsFixed(2),
      'unit': 'μS',
      'icon': Icons.bolt_outlined,
      'color': Color(0xFFFFD54F),
    },
  };
}


  final List<Map<String, dynamic>> alerts = [
    {
      'title': 'Low pH Level',
      'description': 'pH dropped below optimal range',
      'time': '15 min ago',
      'priority': 'High',
      'color': Color(0xFFEF5350),
    },
    {
      'title': 'Irrigation Due',
      'description': 'Soil moisture dropping',
      'time': '1 hour ago',
      'priority': 'Medium',
      'color': Color(0xFFFFB74D),
    },
  ];

  final List<Map<String, dynamic>> crops = [
    {
      'id': 'A1',
      'status': 'Healthy',
      'statusColor': Color(0xFF66BB6A),
      'image': 'assets/lettuce1.jpg',
    },
    {
      'id': 'B2',
      'status': 'Bacterial',
      'statusColor': Color(0xFFEF5350),
      'image': 'assets/lettuce2.jpg',
    },
    {
      'id': 'C3',
      'status': 'Fungal',
      'statusColor': Color(0xFFFFB74D),
      'image': 'assets/lettuce3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 60, 20, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24),
                  _buildSoilParametersSection(),
                  SizedBox(height: 24),
                  //_buildMiniCharts(),
                  SizedBox(height: 24),
                  _buildEmergencyAssistance(),
                  SizedBox(height: 24),
                  _buildAlertsSection(),
                  SizedBox(height: 24),
                  //_buildCropIssuesSection(),
                  SizedBox(height: 24),
                  _buildQuickActions(),
                  SizedBox(height: 40),
                ],
              ),
            ),
            _buildAppBar(),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFF5F7FA),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.eco_outlined,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'AgroSense',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E3A59),
              ),
            ),
            SizedBox(height: 4),
            Text(
              currentDate,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8F9BB3),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                offset: Offset(0, 2),
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }

 Widget _buildSoilParametersSection() {
  // Accessing the SensorProvider to get the real-time sensor data
  final sensor = Provider.of<SensorProvider>(context);
  final soilParameters = getSoilParameters(sensor); // Get live parameters

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Soil Parameters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh, size: 14, color: Color(0xFF4CAF50)),
                SizedBox(width: 4),
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: 16),
      // Grid view to display the parameters dynamically
      GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: soilParameters.length,
        itemBuilder: (context, index) {
          String key = soilParameters.keys.elementAt(index);
          Map<String, dynamic> parameter = soilParameters[key];
          return _buildParameterCard(key, parameter);
        },
      ),
    ],
  );
}


  Widget _buildParameterCard(String title, Map<String, dynamic> parameter) {
    return Container(
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
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: parameter['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              parameter['icon'],
              color: parameter['color'],
              size: 20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8F9BB3),
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                parameter['value'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E3A59),
                ),
              ),
              Text(
                parameter['unit'],
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8F9BB3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 

  Widget _buildEmergencyAssistance() {
    return GestureDetector(
      onTap: () {
        // Handle emergency call
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connecting to agricultural expert...')),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFE53935)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFEF5350).withOpacity(0.3),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_in_talk,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Assistance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get immediate help from experts',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3A59),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
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
              child: _buildAlertItem(alert),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alert['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: alert['color'],
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  alert['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8F9BB3),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF8F9BB3),
                    ),
                    SizedBox(width: 4),
                    Text(
                      alert['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8F9BB3),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: alert['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert['priority'],
                        style: TextStyle(
                          fontSize: 10,
                          color: alert['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert,
            color: Color(0xFF8F9BB3),
          ),
        ],
      ),
    );
  }

  

  Widget _buildQuickActions() {
    final List<Map<String, dynamic>> actions = [
      {'title': 'Scan Lettuce', 'icon': Icons.camera_alt_outlined, 'color': Color.fromARGB(255, 25, 165, 230)},
      {'title': 'CropAI', 'icon': Icons.chat, 'color': Color.fromARGB(255, 17, 165, 4)},
    ];

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
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actions.map((action) {
              return GestureDetector(
                onTap: () {},
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: action['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'],
                        color: action['color'],
                        size: 24,
                      ),
                    ),
                    SizedBox(height: 8), 
                    Text(
                      action['title'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8F9BB3),
                        fontWeight: FontWeight.w500,
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

  Widget _buildBottomNavigation() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, 4),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
            _buildNavItem(1, Icons.bug_report, 'Disease Detection'),
            _buildNavItem(2, Icons.eco_outlined, 'Soil Parameters'),
            _buildNavItem(3, Icons.chat_outlined, 'CropAI'),
          ],
        ),
      ),
    );
  }



  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        
        // Navigate based on selected index
         if (index == 0 ) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgroSenseApp()),
          );
        }

        else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiseaseDetectionScreen()),
          );
        }
        else if (index == 2){
          Navigator.push(context,
           MaterialPageRoute(builder: (context) => SimpleSoilAnalysisScreen()),
          );
        }
        else if (index == 3){
          Navigator.push(context,
           MaterialPageRoute(builder: (context) => ChatbotPage()),
          );
        }
        // Add navigation for other indices if needed
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? Color.fromARGB(255, 3, 110, 9) :  Color.fromARGB(255, 3, 110, 9),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ?  Color.fromARGB(255, 3, 110, 9) : Color.fromARGB(255, 3, 110, 9),
              //fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

