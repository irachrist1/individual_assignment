import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled =
          prefs.getBool('location_notifications') ?? false;
      _loadingPrefs = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_notifications', value);
    setState(() => _notificationsEnabled = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'Location notifications enabled.'
              : 'Location notifications disabled.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign Out',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _loadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Profile card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Text(
                          _initials(profile?.displayName ?? user?.email ?? 'U'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.displayName ??
                                  user?.displayName ??
                                  'User',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  user?.emailVerified == true
                                      ? Icons.verified
                                      : Icons.warning,
                                  size: 14,
                                  color: user?.emailVerified == true
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user?.emailVerified == true
                                      ? 'Email Verified'
                                      : 'Email Not Verified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: user?.emailVerified == true
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification settings
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'Preferences',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile(
                    title: const Text('Location Notifications'),
                    subtitle: const Text(
                        'Get notified about nearby services and places'),
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    secondary: const Icon(
                        Icons.notifications_outlined, color: Colors.blue),
                  ),
                ),

                const SizedBox(height: 16),

                // Account section
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    'Account',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline,
                            color: Colors.blue),
                        title: const Text('App Version'),
                        trailing: const Text('1.0.0',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      const Divider(height: 1, indent: 16),
                      ListTile(
                        leading:
                            const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Sign Out',
                            style: TextStyle(color: Colors.red)),
                        onTap: () => _signOut(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
