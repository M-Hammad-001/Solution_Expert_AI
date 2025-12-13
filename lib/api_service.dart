import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiService {
  // ✅ FIXED: Removed trailing /api/
  static const String baseUrl = 'http://localhost:3000';

  static String? _token;
  static Map<String, dynamic>? _currentUser;
  static GenerativeModel? _geminiModel;

  // ✅ Initialize Gemini AI
  static Future<void> initGemini() async {
    const apiKey = 'AIzaSyBCwvXbg0An2Nt-WFTWKgApeS49FhDMZKc';

    _geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash', // Using the latest stable model
      apiKey: apiKey,
    );
    print('✅ Gemini AI initialized');
  }

  static void setToken(String token) {
    _token = token;
    print('✅ Token set: ${token.substring(0, 10)}...');
  }

  static String? get token => _token;

  // ==================== REGISTER ====================
  static Future<Map<String, dynamic>> register(
      String name,
      String dob,
      String email,
      String password,
      ) async {
    try {
      print('📡 Registering at: $baseUrl/api/register');

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'dob': dob,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📥 Register response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw error['error'] ?? 'Registration failed';
      }
    } catch (e) {
      print('❌ Register error: $e');
      throw 'Registration failed: $e';
    }
  }

  // ==================== LOGIN ====================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('📡 Logging in at: $baseUrl/api/login');

      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📥 Login response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          _currentUser = data;
          setToken(data['token']);
        }
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw error['error'] ?? 'Login failed';
      }
    } catch (e) {
      print('❌ Login error: $e');
      throw 'Login failed: $e';
    }
  }

  // ==================== GUEST LOGIN ====================
  static Future<Map<String, dynamic>> guestLogin() async {
    try {
      print('📡 Guest login at: $baseUrl/api/guest');

      final response = await http.post(
        Uri.parse('$baseUrl/api/guest'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📥 Guest response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          _currentUser = data;
          setToken(data['token']);
        }
        return data;
      } else {
        throw 'Guest login failed';
      }
    } catch (e) {
      print('❌ Guest login error: $e');
      throw 'Guest login failed: $e';
    }
  }

  // ==================== GET CURRENT USER ====================
  static Future<Map<String, dynamic>> getCurrentUser() async {
    if (_currentUser != null) {
      print('✅ Using cached user data');
      return _currentUser!;
    }

    try {
      print('📡 Getting user from: $baseUrl/api/protected/user');
      print('📡 Token: ${_token?.substring(0, 10)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/api/protected/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      print('📥 User response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = data;
        return data;
      } else if (response.statusCode == 401) {
        _token = null;
        _currentUser = null;
        throw 'Session expired. Please login again';
      } else {
        throw 'Failed to get user info';
      }
    } catch (e) {
      print('❌ Get user error: $e');
      throw e;
    }
  }

  // ==================== GET MESSAGES ====================
  static Future<List<dynamic>> getMessages() async {
    try {
      print('📡 Getting messages from: $baseUrl/api/protected/messages');

      final response = await http.get(
        Uri.parse('$baseUrl/api/protected/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      print('📥 Messages response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Get messages error: $e');
      return [];
    }
  }

  // ==================== SEND SMART MESSAGE WITH GEMINI AI ====================
  static Future<Map<String, dynamic>> sendSmartMessage(String text) async {
    try {
      print('📡 Sending smart message...');

      // Initialize Gemini if not already done
      if (_geminiModel == null) {
        await initGemini();
      }

      // 1. Send USER message to backend
      final userResponse = await _sendToBackend(
        text,
        username: _currentUser?['name'] ?? 'You',
        isAI: false,
      );
      print('✅ User message saved');

      // 2. Get AI response from Gemini
      String aiResponseText;
      try {
        print('🤖 Getting Gemini AI response...');
        final content = await _geminiModel!.generateContent([Content.text(text)]);
        aiResponseText = content.text ?? 'Sorry, I could not process that.';
        print('✅ Gemini responded');
      } catch (e) {
        print('⚠️ Gemini error, using fallback: $e');
        aiResponseText = _generateFallbackResponse(text);
      }

      // 3. Send AI response to backend
      final aiResponse = await _sendToBackend(
        aiResponseText,
        username: 'AI Assistant',
        isAI: true,
      );
      print('✅ AI message saved');

      return {
        'user': userResponse,
        'ai': aiResponse,
      };
    } catch (e) {
      print('❌ Send message error: $e');
      throw 'Failed to send message: $e';
    }
  }

  // ==================== INTERNAL: SEND TO BACKEND ====================
  static Future<Map<String, dynamic>> _sendToBackend(
      String text, {
        required String username,
        bool isAI = false,
      }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/protected/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'text': text,
        'isAI': isAI,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    data['username'] = username;
    data['isAI'] = isAI;
    return data;
  }

  // ==================== FALLBACK AI RESPONSE ====================
  static String _generateFallbackResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('hello') || msg.contains('hi')) {
      return 'Hello! How can I assist you today? 👋';
    } else if (msg.contains('help')) {
      return 'I\'m here to help! Ask me about:\n• Coding questions\n• Tech advice\n• General information';
    } else if (msg.contains('flutter')) {
      return 'Flutter is an amazing framework! Are you building something cool? 🚀';
    } else if (msg.contains('error') || msg.contains('bug')) {
      return 'Let\'s debug this together! Can you share more details about the error?';
    } else if (msg.contains('thank')) {
      return 'You\'re welcome! Happy to help! 😊';
    } else {
      return 'I understand your question. Let me help you with that! Could you provide more details?';
    }
  }

  // ==================== SIMPLE SEND MESSAGE (NO AI) ====================
  static Future<Map<String, dynamic>> sendMessage(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/protected/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to send message';
      }
    } catch (e) {
      print('❌ Send message error: $e');
      throw e;
    }
  }

  // ==================== LOGOUT ====================
  static Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/api/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
      _token = null;
      _currentUser = null;
      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
      _token = null;
      _currentUser = null;
    }
  }
}