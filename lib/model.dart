import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

class PlantDiseaseModel extends ChangeNotifier {
  // Server URL - update this with your actual server URL
  final String baseUrl;
  
  // Prediction result
  String? _prediction;
  String? get prediction => _prediction;
  bool get hasPrediction => _prediction != null;
  
  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  PlantDiseaseModel({this.baseUrl = 'http://10.0.2.2:8080'});

  /// Reset the model state
  void reset() {
    _prediction = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Predict disease from a file path
  Future<void> predictFromPath(String imagePath) async {
    final file = File(imagePath);
    return _predict(file);
  }

  /// Sends an image to the Flask server for plant disease prediction
  /// Updates the prediction state and notifies listeners
  Future<void> _predict(File imageFile) async {
    _isLoading = true;
    _prediction = null;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      
      // Add the image file to the request
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: 'plant_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _prediction = data['prediction'];
        _isLoading = false;
        notifyListeners();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = 'Server error: ${errorData['error']}';
        _isLoading = false;
        notifyListeners();
        throw Exception('Failed to get prediction: ${errorData['error']}');
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      throw Exception('Error sending image for prediction: $e');
    }
  }
}