import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SensorProvider with ChangeNotifier {
  // Sensor data storage
  Map<String, dynamic>? latestRecord;
  double temperature = 0.0;
  double moisture = 0.0;
  double ph = 0.0;
  int ec = 0;
  int salinity = 0;
  String lastUpdated = 'Never';
  
  // Table connection management
  String _currentTableName = '';
  String get currentTableName => _currentTableName;
  bool get isConnected => _currentTableName.isNotEmpty;
  
  // Status tracking
  bool isLoading = true;
  String errorMessage = '';
  Timer? _timer;
  late final SupabaseClient _supabaseClient;
  
  // Configuration from .env
  final String _supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final String _supabaseKey = dotenv.env['SUPABASE_ANON_KEY']!;
  final String _smsApiKey = dotenv.env['SMS_API_KEY'] ?? '';
  final String _smsRecipient = dotenv.env['SMS_RECIPIENT'] ?? '';
  final String _smsSenderId = dotenv.env['SMS_SENDER_ID'] ?? '';
  
  // Operational parameters
  Duration _refreshInterval = const Duration(seconds: 5);
  DateTime? _lastNotificationTime;
  final List<Map<String, dynamic>> recommendations = [];

  SensorProvider() {
    WidgetsFlutterBinding.ensureInitialized();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    try {
      isLoading = true;
      notifyListeners();
      
      try {
        _supabaseClient = Supabase.instance.client;
      } catch (e) {
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
      errorMessage = 'Failed to initialize connection: $e';
      isLoading = false;
      notifyListeners();
      debugPrint('Initialization error: $e\n$stackTrace');
    }
  }

  Future<void> connectToTable(String tableName) async {
    if (!_isValidTableName(tableName)) {
      throw ArgumentError('Invalid table name format');
    }

    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();
      
      if (_currentTableName.isNotEmpty) stopListening();
      
      _currentTableName = tableName;
      await _testDatabaseAccess();
      await _fetchLatestSensorData();
      startListening();
    } catch (e) {
      _currentTableName = '';
      errorMessage = 'Connection failed: ${e.toString()}';
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _isValidTableName(String name) {
    return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]{0,62}$').hasMatch(name);
  }

  Future<void> _testDatabaseAccess() async {
    try {
      await _supabaseClient
          .from(_currentTableName)
          .select()
          .limit(1)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception('Table access failed: $e');
    }
  }

  void startListening({Duration? interval}) {
    stopListening();
    if (_currentTableName.isEmpty) return;
    
    _refreshInterval = interval ?? _refreshInterval;
    _fetchLatestSensorData();
    _timer = Timer.periodic(_refreshInterval, (_) => _fetchLatestSensorData());
  }

  void stopListening() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchLatestSensorData() async {
    if (_currentTableName.isEmpty) return;
    
    try {
      isLoading = true;
      notifyListeners();
      
      final response = await _supabaseClient
          .from(_currentTableName)
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single()
          .timeout(const Duration(seconds: 10));
      
      _processSensorData(response);
      _checkEcLevel();
      
    } on SocketException catch (e) {
      errorMessage = 'Network error: ${e.message}';
    } on TimeoutException {
      errorMessage = 'Request timed out';
    } catch (e, stackTrace) {
      errorMessage = 'Data fetch failed';
      debugPrint('Fetch error: $e\n$stackTrace');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _processSensorData(Map<String, dynamic> data) {
    latestRecord = Map<String, dynamic>.from(data);
    temperature = _parseDoubleValue(data['temperature']);
    moisture = _parseDoubleValue(data['moisture']);
    ph = _parseDoubleValue(data['ph']);
    ec = _parseIntValue(data['ec']);
    salinity = _parseIntValue(data['salinity']);
    
    if (data['created_at'] != null) {
      final localTime = DateTime.parse(data['created_at']).toLocal();
      lastUpdated = '${_twoDigits(localTime.hour)}:${_twoDigits(localTime.minute)} '
                   '${_twoDigits(localTime.day)}/${_twoDigits(localTime.month)}/${localTime.year}';
    }
  }

  void _checkEcLevel() {
    recommendations.clear();
    
    if (ec < 500) {
      recommendations.add({
        'title': 'Low Nutrients',
        'description': 'EC level is too low. Apply fertilizer.',
        'icon': Icons.bolt_outlined,
        'color': Colors.amber,
      });
      _sendLowEcNotification();
    }

  }

  // this function is to send the sms 
  Future<void> _sendLowEcNotification() async {
    final now = DateTime.now();
    if (_lastNotificationTime != null && 
        now.difference(_lastNotificationTime!) < const Duration(hours: 1)) {
      return;
    }

    if (_smsApiKey.isEmpty || _smsRecipient.isEmpty) return;

    try {
      final response = await http.get(
        Uri.https(
          'sms.nalosolutions.com',
          '/smsbackend/clientapi/Resl_Nalo/send-message/',
          {
            'key': _smsApiKey,
            'type': '0',
            'destination': _smsRecipient,
            'dlr': '1',
            'source': _smsSenderId,
            'message': 'ALERT: Low soil EC ($ec μS/cm). Fertilize when possible.',
          },
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _lastNotificationTime = now;
        debugPrint('SMS sent successfully');
      }
    } catch (e) {
      debugPrint('SMS send error: $e');
    }
  }

  Future<void> refreshData() async {
    if (_currentTableName.isNotEmpty) {
      await _fetchLatestSensorData();
    }
  }

String _twoDigits(int n) => n.toString().padLeft(2, '0');

double _parseDoubleValue(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  
  final cleaned = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(cleaned) ?? 0.0;
}

int _parseIntValue(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  
  final cleaned = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(cleaned) ?? 0;
}

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}