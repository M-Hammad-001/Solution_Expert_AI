// ==================== FILE: home_screen.dart ====================

import 'package:flutter/material.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Sample chat history
  final List<Map<String, String>> chatHistory = [
    {"title": "Flutter App Development", "time": "2 hours ago"},
    {"title": "API Integration Help", "time": "Yesterday"},
    {"title": "UI Design Tips", "time": "2 days ago"},
    {"title": "Database Query", "time": "3 days ago"},
    {"title": "Authentication Setup", "time": "1 week ago"},
  ];

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
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.wb_sunny : Icons.dark_mode,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: isDarkMode ? Colors.white54 : Colors.black26,
            ),
            const SizedBox(height: 20),
            Text(
              'Start a new conversation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ask me anything...',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildMessageInput(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      child: Column(
        children: [
          // Drawer Header with New Chat and Search
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                // New Chat Button
                ListTile(
                  leading: Icon(
                    Icons.edit_note,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
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
                    // Handle new chat
                  },
                ),
                const SizedBox(height: 8),
                // Search Chats
                ListTile(
                  leading: Icon(
                    Icons.search,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    'Search chats',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle search
                  },
                ),
                const SizedBox(height: 16),
                Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
              ],
            ),
          ),

          // Your Chats Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Chats',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ),

          // Chat History List
          Expanded(
            child: ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  title: Text(
                    chatHistory[index]["title"]!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    chatHistory[index]["time"]!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle chat selection
                  },
                );
              },
            ),
          ),

          // User Info and Settings at Bottom
          Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF9333EA),
              child: const Text(
                'U',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              'User Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              'Premium Plan',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen(isDarkMode: isDarkMode)),
              );
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
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.black45,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF9333EA),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                // Handle send message
              },
            ),
          ),
        ],
      ),
    );
  }
}