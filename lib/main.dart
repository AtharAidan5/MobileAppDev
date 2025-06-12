import 'package:flutter/material.dart';

// New class (AppTheme) to hold a global (static) variable for the theme mode.
class AppTheme {
  static bool isDarkMode = false;
  static ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);
  static ThemeData get lightTheme =>
      ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light);
  static ThemeData get darkTheme =>
      ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a ValueListenableBuilder (or a static getter) so that the app rebuilds when the theme changes.
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'Certify App',
          debugShowCheckedModeBanner: false,
          theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CertificatesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certify App'), centerTitle: true),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Certificates',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(
                context,
                Icons.add,
                'Create',
                Colors.blue,
                () => debugPrint('Create tapped'),
              ),
              _buildActionCard(
                context,
                Icons.upload,
                'Upload',
                Colors.green,
                () => debugPrint('Upload tapped'),
              ),
              _buildActionCard(
                context,
                Icons.share,
                'Share',
                Colors.orange,
                () => debugPrint('Share tapped'),
              ),
              _buildActionCard(
                context,
                Icons.settings,
                'Settings',
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder:
                (context, index) => ListTile(
                  leading: const Icon(Icons.assignment_turned_in),
                  title: Text('Certificate ${index + 1}'),
                  subtitle: const Text('Issued on 2023-06-01'),
                  trailing: const Icon(Icons.chevron_right),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder:
          (context, index) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.verified, color: Colors.green),
              title: Text('Certificate ${index + 1}'),
              subtitle: const Text('Organization: UPM'),
              trailing: const Icon(Icons.more_vert),
            ),
          ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Athar Aidan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('123456@student.upm.edu.my'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => debugPrint('Logout pressed'),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: [
          _buildSettingsTile(
            context,
            Icons.notifications,
            'Notifications',
            'Manage your notification preferences.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                ),
          ),
          _buildSettingsTile(
            context,
            Icons.security,
            'Security',
            'Change password and security settings.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityScreen(),
                  ),
                ),
          ),
          _buildSettingsTile(
            context,
            Icons.color_lens,
            'Theme',
            'Adjust app theme and appearance.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThemeScreen()),
                ),
          ),
          _buildSettingsTile(
            context,
            Icons.info,
            'About',
            'Information about Certify App.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                ),
          ),
          _buildSettingsTile(
            context,
            Icons.help,
            'Help & Support',
            'Get help or contact support.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? Colors.white : Theme.of(context).primaryColor,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}

// New NotificationsScreen (a StatefulWidget) for the Notifications tile
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _enableNotifications = true;
  bool _enableEmailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"), centerTitle: true),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Enable Notifications"),
            subtitle: const Text(
              "Receive notifications for new certificates and updates.",
            ),
            value: _enableNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text("Email Notifications"),
            subtitle: const Text("Receive notifications via email."),
            value: _enableEmailNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableEmailNotifications = value;
              });
            },
          ),
          if (_enableEmailNotifications)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Emails will be sent to this address: 123456@student.upm.edu.my',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
        ],
      ),
    );
  }
}

// Re-insert SecurityScreen (a StatefulWidget) for the Security tile (with "Change Password" (a dialog) and a "Security Options" (a 2FA toggle)).
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _enable2FA = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Old Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint('Password change requested');
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Security Options',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Enable Two-Factor Authentication (2FA)'),
              subtitle: const Text(
                'Add an extra layer of security to your account.',
              ),
              value: _enable2FA,
              onChanged: (bool value) {
                setState(() {
                  _enable2FA = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showChangePasswordDialog,
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}

// Update ThemeScreen so that toggling the switch updates the global (static) variable (and notifies listeners).
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  bool _isDarkMode = AppTheme.isDarkModeNotifier.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme'), centerTitle: true),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark mode.'),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
              });
              // Update the global (static) variable (and notify listeners) so that the app's theme is updated.
              AppTheme.isDarkModeNotifier.value = value;
              debugPrint('Theme toggled: ${_isDarkMode ? "Dark" : "Light"}');
            },
          ),
        ],
      ),
    );
  }
}

// New AboutScreen (a StatelessWidget) for the About tile
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), centerTitle: true),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Certify App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(title: const Text('Version'), subtitle: const Text('1.0.0')),
          ListTile(
            title: const Text('Copyright'),
            subtitle: const Text('© 2025 Certify App'),
          ),
          ListTile(
            title: const Text('Terms & Privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => debugPrint('Terms & Privacy pressed'),
          ),
        ],
      ),
    );
  }
}

// New HelpSupportScreen (a StatelessWidget) for the Help & Support tile
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Your Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => debugPrint('Send pressed'),
              child: const Text('Send'),
            ),
            const SizedBox(height: 24),
            const Text(
              'FAQ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final faqTitles = [
                  'How do I create a certificate?',
                  'How do I share my certificate?',
                  'How do I update my profile?',
                ];
                return ListTile(
                  title: Text(faqTitles[index]),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => debugPrint('FAQ item ${index + 1} tapped'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
