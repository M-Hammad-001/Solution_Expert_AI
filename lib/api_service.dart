import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart'; // ✅ Correct package

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/'; // ✅ Unchanged
  static String? _token;
  static Map<String, dynamic>? _currentUser;
  static GenerativeModel? _geminiModel;

  // ✅ FIXED GEMINI INIT (Correct package + no dotenv needed)
  static Future<void> initGemini() async {
    const apiKey = 'AIzaSyBCwvXbg0An2Nt-WFTWKgApeS49FhDMZKc'; // ✅ Your key hardcoded

    _geminiModel = GenerativeModel(
      model: 'gemini-1.0-pro',   // or 'gemini-1.5-pro-latest'
      apiKey: apiKey,
    );
  }

  static void setToken(String token) {
    _token = token;
  }

  static String? get token => _token;

  // ✅ YOUR EXISTING METHODS (UNCHANGED)
  static Future<Map<String, dynamic>> register(String name, String dob, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'dob': dob, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw jsonDecode(response.body)['error'] ?? 'Registration failed';
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      _currentUser = data;
      setToken(data['token']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> guestLogin() async {
    final response = await http.post(Uri.parse('$baseUrl/guest'));
    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      _currentUser = data;
      setToken(data['token']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    if (_currentUser != null) return _currentUser!;

    final response = await http.get(
      Uri.parse('$baseUrl/protected/user'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    final data = jsonDecode(response.body);
    _currentUser = data;
    return data;
  }

  static Future<List<dynamic>> getMessages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/protected/messages'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    return jsonDecode(response.body);
  }

  // ✅ FIXED: SMART MESSAGE WITH GEMINI AI RESPONSE
  static Future<Map<String, dynamic>> sendSmartMessage(String text) async {
    if (_geminiModel == null) throw Exception('Gemini not initialized. Call initGemini() first.');

    try {
      // 1. Save USER message to backend FIRST
      final userResponse = await _sendToBackend(text, username: _currentUser?['name'] ?? 'You');

      // 2. Get GEMINI AI response
      final content = await _geminiModel!.generateContent([Content.text(text)]);
      final aiResponseText = content.text ?? 'Sorry, I could not process that.';

      // 3. Save AI response to backend
      final aiResponse = await _sendToBackend(aiResponseText, username: 'AI Assistant', isAI: true);

      return {
        'user': userResponse,
        'ai': aiResponse,
      };
    } catch (e) {
      // ✅ FIXED: Declare userResponse before try block for fallback
      final fallbackResponse = await _sendToBackend(
          'Sorry, AI is temporarily unavailable: $e',
          username: 'AI Assistant',
          isAI: true
      );
      return {
        'user': null, // No user message on full error
        'ai': fallbackResponse,
      };
    }
  }

  // ✅ OLD: Simple message (no AI)
  static Future<Map<String, dynamic>> sendMessage(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/protected/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({'text': text}),
    );
    return jsonDecode(response.body);
  }

  // ✅ FIXED: INTERNAL sendToBackend
  static Future<Map<String, dynamic>> _sendToBackend(String text, {required String username, bool isAI = false}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/protected/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'text': text,
        'isAI': isAI,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    data['username'] = username;
    data['isAI'] = isAI;
    return data;
  }

  static Future<void> logout() async {
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    _token = null;
    _currentUser = null;
  }
}
