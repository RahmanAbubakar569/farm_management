import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SensorProvider with ChangeNotifier {
  // Store only the latest sensor data record
  Map<String, dynamic>? latestRecord;
  
  // Soil parameter values
  double temperature = 0.0;
  double moisture = 0.0;
  double ph = 0.0;
  int ec = 0;
  int salinity = 0;
  String lastUpdated = 'Never';
  
  // Current table management
  String _currentTableName = '';
  String get currentTableName => _currentTableName;
  bool get isConnected => _currentTableName.isNotEmpty;
  
  // Loading state
  bool isLoading = true;
  String errorMessage = '';

  Timer? _timer;
  late final SupabaseClient _supabaseClient;
  
  // Supabase configuration
  final String _supabaseUrl = 'https://rpsnooqnkgajqegdzvbh.supabase.co';
  final String _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwc25vb3Fua2dhanFlZ2R6dmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxOTExNTAsImV4cCI6MjA2MTc2NzE1MH0.zpSC3jDarWFhHrM7lQ2gTszA-vuA9xJJCLX9V1Wh424';
  
  // Refresh interval (default 5 seconds)
  Duration _refreshInterval = const Duration(seconds: 5);

  // Constructor
  SensorProvider() {
    WidgetsFlutterBinding.ensureInitialized();
    _initializeSupabase();
  }
  
  // Initialize Supabase client
  Future<void> _initializeSupabase() async {
    try {
      debugPrint('Initializing Supabase connection...');
      isLoading = true;
      notifyListeners();
      
      try {
        _supabaseClient = Supabase.instance.client;
        debugPrint('Using existing Supabase client');
      } catch (e) {
        debugPrint('Initializing new Supabase client');
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _supabaseKey,
          debug: true,
        );
        _supabaseClient = Supabase.instance.client;
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error in _initializeSupabase: $e');
      debugPrint(stackTrace.toString());
      errorMessage = 'Failed to initialize connection: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  // Connect to a specific table
  Future<void> connectToTable(String tableName) async {
    if (!_isValidTableName(tableName)) {
      throw ArgumentError('Invalid table name. Only alphanumeric characters and underscores are allowed.');
    }

    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();
      
      // Disconnect from current table if connected
      if (_currentTableName.isNotEmpty) {
        stopListening();
      }
      
      _currentTableName = tableName;
      await _testDatabaseAccess();
      await _fetchLatestSensorData();
      
      // Start listening only after successful connection
      startListening();
      
      debugPrint('Successfully connected to table: $tableName');
    } catch (e) {
      _currentTableName = '';
      errorMessage = 'Failed to connect to table: ${e.toString()}';
      debugPrint('Connection error: $errorMessage');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _isValidTableName(String name) {
    return name.isNotEmpty && 
           name.length <= 63 &&
           RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(name);
  }

  Future<void> _testDatabaseAccess() async {
    if (_currentTableName.isEmpty) {
      throw StateError('No table name specified');
    }
    
    try {
      final response = await _supabaseClient
          .from(_currentTableName)
          .select()
          .limit(1)
          .timeout(const Duration(seconds: 10));
          
      if (response.isEmpty) {
        debugPrint('Table $_currentTableName exists but is empty');
      }
    } 
    // on SocketException catch (e) {
    //   throw Exception('Network error: ${e.message}');
    // } 
    // on TimeoutException {
    //   throw Exception('Connection timeout. Please check your internet connection.');
    // } 
    catch (e) {
      debugPrint('Error accessing table $_currentTableName: $e');
      throw Exception('Cannot access table $_currentTableName. Please verify the table exists and you have proper permissions.');
    }
  }

  // Start periodic data fetching
  void startListening({Duration? interval}) {
    stopListening(); // Cancel any existing timer
    
    if (_currentTableName.isEmpty) {
      debugPrint('Cannot start listening - no table connected');
      return;
    }
    
    if (interval != null) {
      _refreshInterval = interval;
    }
    
    // Fetch immediately first
    _fetchLatestSensorData();
    
    // Then set up periodic fetching
    _timer = Timer.periodic(_refreshInterval, (timer) async {
      debugPrint('Fetching data...');
      await _fetchLatestSensorData();
    });
    
    debugPrint('Started polling table $_currentTableName every ${_refreshInterval.inSeconds}s');
  }

  // Stop periodic data fetching
  void stopListening() {
    _timer?.cancel();
    _timer = null;
    debugPrint('Stopped data polling');
  }

  // Fetch only the latest sensor data record
  Future<void> _fetchLatestSensorData() async {
    if (_currentTableName.isEmpty) return;
    
    try {
      isLoading = true;
      notifyListeners();
      
      errorMessage = '';
      
      final response = await _supabaseClient
          .from(_currentTableName)
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single()
          .timeout(const Duration(seconds: 10));
      
      latestRecord = Map<String, dynamic>.from(response);
      debugPrint('Fetched data: $latestRecord');
      
      // Process values - handle both string and numeric values
      temperature = _parseDoubleValue(latestRecord!['temperature']);
      moisture = _parseDoubleValue(latestRecord!['moisture']);
      ph = _parseDoubleValue(latestRecord!['ph']);
      ec = _parseIntValue(latestRecord!['ec']);
      salinity = _parseIntValue(latestRecord!['salinity']);
      
      // Format the timestamp for display
      if (latestRecord!['created_at'] != null) {
        final dateTime = DateTime.parse(latestRecord!['created_at']).toLocal();
        lastUpdated = '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)} '
                     '${_twoDigits(dateTime.day)}/${_twoDigits(dateTime.month)}/${dateTime.year}';
      } else {
        lastUpdated = 'Unknown';
      }
      
      debugPrint('Updated values: '
                'temp=$temperature°C, '
                'moisture=$moisture%, '
                'ph=$ph, '
                'ec=$ec μS, '
                'salinity=$salinity mg/L');
      
      isLoading = false;
      notifyListeners();
    } on SocketException catch (e) 
    {
      //errorMessage = 'Network error: ${e.message}';
      isLoading = false;
      notifyListeners();
    } 
    on TimeoutException {
      //errorMessage = 'Request timed out. Please check your internet connection.';
      isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching from $_currentTableName: $e');
      debugPrint(stackTrace.toString());
      errorMessage = 'Failed to fetch data: ${e.toString()}';
      isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper to format two-digit numbers
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Manual refresh
  Future<void> refreshData() async {
    if (_currentTableName.isEmpty) return;
    await _fetchLatestSensorData();
  }

  // Helper methods for value parsing
  double _parseDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      // Remove any non-numeric characters except decimal point
      final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
  
  int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      // Remove any non-numeric characters
      final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }
  
  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}