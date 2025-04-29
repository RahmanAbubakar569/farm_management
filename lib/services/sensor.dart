import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SensorProvider with ChangeNotifier {
  double temperature = 0.0;
  double moisture = 0.0;
  double ph = 0.0;
  int ec = 0;
  int salinity = 0;

  Timer? _timer;

  SensorProvider() {
    startListening();
  }

  void startListening({Duration interval = const Duration(seconds: 5)}) {
    _fetchSensorData();
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _fetchSensorData());
  }

  void stopListening() {
    _timer?.cancel();
  }

  Future<void> _fetchSensorData() async {
    try {
      final response = await http.get(Uri.parse('http://10.42.0.1:5000/data'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        temperature = (data['temperature'] ?? 0).toDouble();
        moisture = (data['moisture'] ?? 0).toDouble();
        ph = (data['ph'] ?? 0).toDouble();
        ec = (data['ec'] ?? 0).toInt();
        salinity = (data['salinity'] ?? 0).toInt();

        notifyListeners(); // notify UI
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }
}
 