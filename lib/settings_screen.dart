// ==================== FILE: settings_screen.dart ====================

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;

  const SettingsScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Details Section
          _buildSectionHeader('User Details', isDarkMode),
          const SizedBox(height: 12),
          _buildUserCard(isDarkMode),
          const SizedBox(height: 24),

          // Current Plan Section
          _buildSectionHeader('Current Plan', isDarkMode),
          const SizedBox(height: 12),
          _buildCurrentPlanCard(isDarkMode),
          const SizedBox(height: 24),

          // Available Plans Section
          _buildSectionHeader('Available Plans', isDarkMode),
          const SizedBox(height: 12),
          _buildPlanCard(
            'Free Plan',
            'Basic features',
            '0',
            'Current Plan',
            true,
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            'Premium Plan',
            'Advanced features & priority support',
            '9.99',
            'Upgrade',
            false,
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            'Pro Plan',
            'All features + API access',
            '19.99',
            'Upgrade',
            false,
            isDarkMode,
          ),
          const SizedBox(height: 24),

          // Account Settings Section
          _buildSectionHeader('Account Settings', isDarkMode),
          const SizedBox(height: 12),
          _buildSettingsTile(
            Icons.person_outline,
            'Edit Profile',
            isDarkMode,
                () {},
          ),
          _buildSettingsTile(
            Icons.lock_outline,
            'Change Password',
            isDarkMode,
                () {},
          ),
         /* _buildSettingsTile(
            Icons.notifications_outline,
            'Notifications',
            isDarkMode,
                () {},
          ),*/
          _buildSettingsTile(
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            isDarkMode,
                () {},
          ),
          _buildSettingsTile(
            Icons.help_outline,
            'Help & Support',
            isDarkMode,
                () {},
          ),
          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton(
            onPressed: () {
              // Handle logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildUserCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFF9333EA),
            child: const Text(
              'U',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'user@email.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since Jan 2024',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Free Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• 50 messages per day\n• Basic chat features\n• Standard response time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      String title,
      String description,
      String price,
      String buttonText,
      bool isCurrent,
      bool isDark,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: const Color(0xFF9333EA), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '\$$price/mo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent ? Colors.grey : const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      IconData icon,
      String title,
      bool isDark,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
      onTap: onTap,
    );
  }
}