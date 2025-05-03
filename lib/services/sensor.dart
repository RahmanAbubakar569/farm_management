import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SensorProvider with ChangeNotifier {
  // List to store all sensor data records
  List<Map<String, dynamic>> sensorRecords = [];
  
  // Soil parameter values for backward compatibility
  double temperature = 0.0;
  double moisture = 0.0;
  double ph = 0.0;
  int ec = 0;
  int salinity = 0;
  String lastUpdated = '';
  
  // Loading state
  bool isLoading = true;
  String errorMessage = '';

  Timer? _timer;
  late final SupabaseClient _supabaseClient;
  
  // Supabase configuration
  final String _supabaseUrl = 'https://rpsnooqnkgajqegdzvbh.supabase.co';
  final String _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwc25vb3Fua2dhanFlZ2R6dmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxOTExNTAsImV4cCI6MjA2MTc2NzE1MH0.zpSC3jDarWFhHrM7lQ2gTszA-vuA9xJJCLX9V1Wh424';
  static const String _tableName = 'farmsensor_data';
  
  // Refresh interval (default 5 seconds)
  Duration _refreshInterval = const Duration(seconds: 5);
  
  // Number of records to fetch (can be adjusted)
  int _recordLimit = 50;

  // Constructor
  SensorProvider() {
    _initializeSupabase();
  }
  
  // Initialize Supabase client and start data fetching
  Future<void> _initializeSupabase() async {
    try {
      debugPrint('Initializing Supabase connection...');
      isLoading = true;
      notifyListeners();
      
      try {
        // Get existing Supabase client if available
        _supabaseClient = Supabase.instance.client;
        debugPrint('Using existing Supabase client');
      } catch (e) {
        // Initialize Supabase if needed
        debugPrint('Initializing new Supabase client');
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _supabaseKey,
          debug: true, // Enable debug mode to see more detailed logs
        );
        _supabaseClient = Supabase.instance.client;
      }
      
      // Verify data access
      await _testDatabaseAccess();
      
      // Initial data fetch
      await _fetchAllSensorData();
      
      // Slight delay before starting the timer to ensure initial fetch completes
      Future.delayed(Duration(milliseconds: 500), () {
        startListening();
      });
      
    } catch (e, stackTrace) {
      debugPrint('Error in _initializeSupabase: $e');
      debugPrint(stackTrace.toString());
      errorMessage = 'Failed to initialize connection: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  // Test database access to ensure table exists and is accessible
  Future<void> _testDatabaseAccess() async {
    try {
      final testQuery = await _supabaseClient
          .from(_tableName)
          .select('count')
          .limit(1);
      debugPrint('Successfully connected to $_tableName table');
    } catch (e) {
      debugPrint('Error accessing $_tableName table: $e');
      throw Exception('Cannot access $_tableName table. Please check if the table exists and has proper permissions.');
    }
  }

  // Start periodic data fetching
  void startListening({Duration? interval}) {
    // If a new interval is provided, use it
    if (interval != null) {
      _refreshInterval = interval;
    }
    
    // Cancel any existing timer
    _timer?.cancel();
    
    // Start a new timer with the specified interval
    _timer = Timer.periodic(_refreshInterval, (timer) {
      debugPrint('Timer triggered: fetching data (timer tick: ${timer.tick})');
      _fetchAllSensorData();
    });
    debugPrint('Started sensor data polling with ${_refreshInterval.inSeconds}s interval');
  }

  // Stop periodic data fetching
  void stopListening() {
    _timer?.cancel();
    _timer = null;
    debugPrint('Stopped sensor data polling');
  }

  // Set a new refresh interval
  void setRefreshInterval(Duration interval) {
    _refreshInterval = interval;
    
    // If already listening, restart with new interval
    if (_timer != null) {
      stopListening();
      startListening();
    }
  }
  
  // Set the number of records to fetch
  void setRecordLimit(int limit) {
    _recordLimit = limit;
    _fetchAllSensorData(); // Refresh with new limit
  }

  // Fetch all sensor data up to the record limit
  Future<void> _fetchAllSensorData() async {
    try {
      debugPrint('Fetching sensor data records...');
      // Only set isLoading to true on initial load, not on refresh
      if (sensorRecords.isEmpty) {
        isLoading = true;
        notifyListeners();
      }
      errorMessage = '';
      
      // Query multiple records, ordered by creation time (newest first)
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .order('created_at', ascending: false)
          .limit(_recordLimit);
      
      if (response != null && response.isNotEmpty) {
        // Clear existing records and add new ones to ensure fresh data
        sensorRecords = [];
        sensorRecords = List<Map<String, dynamic>>.from(response);
        
        // Process records for display
        for (var record in sensorRecords) {
          // Format temperature, moisture, pH as double values
          record['temperature'] = _parseDoubleValue(record['temperature']);
          record['moisture'] = _parseDoubleValue(record['moisture']);
          record['ph'] = _parseDoubleValue(record['ph']);
          
          // Format EC and salinity as integers
          record['ec'] = _parseIntValue(record['ec']);
          record['salinity'] = _parseIntValue(record['salinity']);
          
          // Format timestamp
          if (record['created_at'] != null) {
            DateTime dateTime = DateTime.parse(record['created_at']);
            record['formatted_time'] = dateTime.toLocal().toString();
          }
        }
        
        // Update the single-value properties for backward compatibility
        if (sensorRecords.isNotEmpty) {
          var latest = sensorRecords.first;
          temperature = latest['temperature'] ?? 0.0;
          moisture = latest['moisture'] ?? 0.0;
          ph = latest['ph'] ?? 0.0;
          ec = latest['ec'] ?? 0;
          salinity = latest['salinity'] ?? 0;
          
          if (latest['created_at'] != null) {
            DateTime dateTime = DateTime.parse(latest['created_at']);
            lastUpdated = dateTime.toLocal().toString();
          }
        }
        
        debugPrint('Retrieved ${sensorRecords.length} sensor records');
        debugPrint('Latest values - Temperature: $temperature, Moisture: $moisture, pH: $ph, EC: $ec, Salinity: $salinity');
        
        isLoading = false;
        notifyListeners();
      } else {
        debugPrint('No sensor data found in database');
        sensorRecords = [];
        errorMessage = 'No sensor data available';
        isLoading = false;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching sensor data: $e');
      debugPrint(stackTrace.toString());
      errorMessage = 'Failed to fetch sensor data: $e';
      isLoading = false;
      notifyListeners();
    }
  }
  
  // Manual refresh - can be called from UI
  Future<void> refreshData() async {
    debugPrint('Manual refresh requested');
    await _fetchAllSensorData();
  }

  // Helper method to safely parse double values
  double _parseDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    
    try {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (e) {
      debugPrint('Error parsing double value: $e');
      return 0.0;
    }
  }
  
  // Helper method to safely parse integer values
  int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    
    try {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    } catch (e) {
      debugPrint('Error parsing int value: $e');
      return 0;
    }
  }
  
  // Clean up resources when provider is disposed
  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}