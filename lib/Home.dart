// ==================== FILE 2: home_screen.dart ====================

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await ApiService.getCurrentUser();
      if (mounted) {
        setState(() {
          currentUser = user;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      final msgs = await ApiService.getMessages();
      if (mounted) {
        setState(() {
          messages = msgs;
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final text = _messageController.text.trim();
    _messageController.clear();
    setState(() => _isSending = true);

    try {
      final result = await ApiService.sendSmartMessage(text);

      if (mounted) {
        setState(() {
          messages.addAll([result['user'], result['ai']]);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Send failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Solution Expert AI',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.wb_sunny : Icons.dark_mode,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => setState(() => isDarkMode = !isDarkMode),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: messages.isEmpty ? _buildEmptyState() : _buildChatList(),
      bottomNavigationBar: _buildMessageInput(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy,
            size: 80,
            color: isDarkMode ? Colors.white54 : Colors.green[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'AI Chatbot Ready!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ask me anything about coding, tech, or general questions...',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.grey[100],
          child: Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Chat (${messages.length} messages)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[messages.length - 1 - index];
              return _buildMessageTile(msg);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> msg) {
    final isAI = msg['isAI'] == true;
    final usernameInitial = (msg['username'] ?? 'U')[0].toUpperCase();
    final screenWidth = MediaQuery.of(context).size.width * 0.7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Icon(Icons.smart_toy, color: Colors.white, size: 24),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(left: 12),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF9333EA),
                child: Text(
                  usernameInitial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
              isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  msg['username'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isAI
                        ? Colors.green[700]!
                        : (isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  constraints: BoxConstraints(maxWidth: screenWidth),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isAI
                        ? (isDarkMode ? Colors.green[900] : Colors.green[50])
                        : (isDarkMode ? const Color(0xFF3D3D3D) : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg['text'] ?? '',
                    style: TextStyle(
                      color: isAI
                          ? (isDarkMode ? Colors.white : Colors.green[800]!)
                          : (isDarkMode ? Colors.white : Colors.black87),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(msg['timestamp']),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return 'Unknown time';
    }
  }

  Widget _buildDrawer() {
    final user = currentUser ?? {
      'name': 'Guest',
      'email': 'guest@example.com',
      'dob': 'N/A',
      'isGuest': true
    };
    final nameInitial = (user['name']?.toString() ?? 'G')[0].toUpperCase();
    final isGuest = user['isGuest'] == true;

    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: isDarkMode ? Colors.green : const Color(0xFF9333EA),
                  child: Text(
                    nameInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user['name'] ?? 'Guest User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? 'guest@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (!isGuest) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cake_outlined,
                        size: 14,
                        color: isDarkMode ? Colors.white54 : Colors.black45,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'DOB: ${user['dob'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isGuest) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Guest Account',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ListTile(
                  leading: Icon(Icons.edit_note, color: isDarkMode ? Colors.white : Colors.black),
                  title: Text(
                    'New Chat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => messages.clear());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black),
                  title: Text(
                    'Search chats',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
                const Divider(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Chats (${messages.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length > 3 ? 3 : messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                return ListTile(
                  leading: Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  title: Text(
                    msg['text'].toString().length > 30
                        ? '${msg['text'].toString().substring(0, 30)}...'
                        : msg['text'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${msg['username']} • ${_formatTime(msg['timestamp'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: isDarkMode ? Colors.white : Colors.black),
            title: Text(
              'Settings',
              style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(isDarkMode: isDarkMode),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
          children: [
      Expanded(
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _messageController,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        onSubmitted: (_) => _sendMessage(),
        enabled: !_isSending,
        decoration: InputDecoration(
          hintText: _isSending ? 'AI is thinking...' : 'Type your message...',
          hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black45),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ),
    ),
    const SizedBox(width: 8),
    CircleAvatar(
    backgroundColor: _isSending ? Colors.grey : const Color(0xFF9333EA),
    radius: 22,
    child: _isSending
    ? const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    )
        : IconButton(
    icon: const Icon(Icons.send, color: Colors.white, size: 20),
    onPressed: _isSending ? null : _sendMessage,
    ),
    ),
          ],
      ),
    );
  }
}