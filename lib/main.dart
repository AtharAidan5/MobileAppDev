import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'upload_screen.dart';
import 'create_certificate_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Theme management
class AppTheme {
  static bool isDarkMode = false;
  static ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1A1A1A),
          secondary: const Color(0xFF00B894),
          tertiary: const Color(0xFF6C5CE7),
          surface: Colors.white,
          background: const Color(0xFFF8F8F8),
          error: const Color(0xFFFF3B30),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: const Color(0xFF1A1A1A),
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: const Color(0xFF1A1A1A),
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.24,
            color: const Color(0xFF1A1A1A),
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00B894),
          secondary: const Color(0xFF6C5CE7),
          tertiary: const Color(0xFF00B894),
          surface: const Color(0xFF2D3436),
          background: const Color(0xFF1A1A1A),
          error: const Color(0xFFFF3B30),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: Colors.white,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.24,
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF2D3436),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
      );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  final GlobalKey _scaffoldKey = GlobalKey();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CertificatesScreen(),
    const UploadScreen(),
    const CreateCertificateScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('CERTIFY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated Background with Parallax Effect
          Positioned.fill(
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: 1 + (0.1 * value),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1557683316-973673baf926?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2029&q=80',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.5),
                    colorBlendMode: BlendMode.darken,
                  ),
                );
              },
            ),
          ),
          // Gradient Overlay with Animation
          Positioned.fill(
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7 * value),
                        Colors.black.withOpacity(0.3 * value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Content with Neumorphic Effect
          _screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.article_outlined, 'Certificates'),
                _buildNavItem(2, Icons.upload_file_outlined, 'Upload'),
                _buildNavItem(3, Icons.add_circle_outline, 'Create'),
                _buildNavItem(4, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await FirestoreService().addCertificate({
            'name': 'Test Certificate',
            'recipient': 'Test User',
            'organization': 'Test Org',
            'purpose': 'Testing Firestore',
            'issuedDate': Timestamp.fromDate(DateTime.now()),
            'expiryDate': null,
            'signature': 'Test Signature',
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sample certificate added!')),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Sample Certificate',
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? (isDark ? Colors.blue[300] : Colors.blue[700])
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.blue[900]?.withOpacity(0.2) : Colors.blue[50])
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.white;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          // Welcome Text with 3D Effect
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    'Welcome back!',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          // Action Cards with Hover Effect
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _buildActionCard(
                context,
                Icons.add_circle_outline,
                'Create',
                const Color(0xFF00B894),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCertificateScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                context,
                Icons.upload_outlined,
                'Upload',
                const Color(0xFF6C5CE7),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                context,
                Icons.share_outlined,
                'Share',
                const Color(0xFF00B894),
                () => debugPrint('Share tapped'),
              ),
              _buildActionCard(
                context,
                Icons.settings_outlined,
                'Settings',
                const Color(0xFF6C5CE7),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Recent Activity with Glass Effect
          Text(
            'Recent Activity',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.verified,
                          color: isDark ? Colors.blue[400] : Colors.blue[600],
                        ),
                      ),
                      title: Text(
                        'Certificate ${index + 1}',
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.white : Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Created ${index + 1} days ago',
                        style: GoogleFonts.inter(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
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
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                spreadRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
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
    return StreamBuilder(
      stream: FirestoreService().getCertificates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No certificates found.'));
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(Icons.verified,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Text(
                  'Recipient: ${data['recipient'] ?? ''}\nOrganization: ${data['organization'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?name=Athar+Aidan&background=00B894&color=fff'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Athar Aidan',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '123456@student.upm.edu.my',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _buildProfileButton(
            context,
            Icons.edit_outlined,
            'Edit Profile',
            () {},
          ),
          const SizedBox(height: 12),
          _buildProfileButton(
            context,
            Icons.logout,
            'Logout',
            () => debugPrint('Logout pressed'),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDestructive ? Theme.of(context).colorScheme.error : null,
          foregroundColor: isDestructive ? Colors.white : null,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(context, 'Preferences', [
            _buildSettingsTile(
              context,
              Icons.notifications_outlined,
              'Notifications',
              'Manage your notification preferences.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              ),
            ),
            _buildSettingsTile(
              context,
              Icons.security_outlined,
              'Security',
              'Change password and security settings.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SecurityScreen(),
                ),
              ),
            ),
            _buildSettingsTile(
              context,
              Icons.color_lens_outlined,
              'Theme',
              'Adjust app theme and appearance.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeScreen(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(context, 'About', [
            _buildSettingsTile(
              context,
              Icons.info_outline,
              'About',
              'Information about Certify App.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              ),
            ),
            _buildSettingsTile(
              context,
              Icons.help_outline,
              'Help & Support',
              'Get help or contact support.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Card(margin: EdgeInsets.zero, child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))
          : null,
      onTap: onTap,
    );
  }
}

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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
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
                const Divider(height: 1),
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
              ],
            ),
          ),
          if (_enableEmailNotifications)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Emails will be sent to this address: 123456@student.upm.edu.my',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }
}

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark mode.'),
              value: AppTheme.isDarkMode,
              onChanged: (bool value) {
                AppTheme.isDarkMode = value;
                AppTheme.isDarkModeNotifier.value = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Implement password change
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Authentication'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // Implement biometric toggle
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, size: 64),
            const SizedBox(height: 16),
            Text(
              'Certify App',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('FAQ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to FAQ
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Contact Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Open email client
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
