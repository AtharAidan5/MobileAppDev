import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Certify App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2D3436), // Dark gray
          secondary: const Color(0xFF00B894), // Mint green
          tertiary: const Color(0xFF6C5CE7), // Purple
          surface: Colors.white,
          background: const Color(0xFFF8F8F8),
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
            color: const Color(0xFF2D3436),
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
            color: const Color(0xFF2D3436),
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
      ),
      home: const HomeScreen(),
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

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CertificatesScreen(),
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
    return Scaffold(
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
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1557683316-973673baf926?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2029&q=80',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          _screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                _buildNavItem(1, Icons.assignment_outlined, Icons.assignment,
                    'Certificates'),
                _buildNavItem(2, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _animationController.forward(from: 0);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100), // Space for app bar
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
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
                const Color(0xFF00B894), // Mint green
                () => debugPrint('Create tapped'),
              ),
              _buildActionCard(
                context,
                Icons.upload_outlined,
                'Upload',
                const Color(0xFF6C5CE7), // Purple
                () => debugPrint('Upload tapped'),
              ),
              _buildActionCard(
                context,
                Icons.share_outlined,
                'Share',
                const Color(0xFF00B894), // Mint green
                () => debugPrint('Share tapped'),
              ),
              _buildActionCard(
                context,
                Icons.settings_outlined,
                'Settings',
                const Color(0xFF6C5CE7), // Purple
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 20),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 20),
                  itemBuilder: (context, index) =>
                      _buildActivityCard(context, index),
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
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, int index) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.assignment_turned_in,
            color: Theme.of(context).colorScheme.secondary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Certificate ${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Issued on 2023-06-01',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
      ],
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
      itemBuilder: (context, index) => _buildCertificateCard(context, index),
    );
  }

  Widget _buildCertificateCard(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.verified,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          'Certificate ${index + 1}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Organization: UPM',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
          ),
          const SizedBox(height: 24),
          Text('Athar Aidan', style: Theme.of(context).textTheme.displayMedium),
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
                  builder: (context) =>
                      const PlaceholderScreen(title: 'Security'),
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
                  builder: (context) => const PlaceholderScreen(title: 'About'),
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
                  builder: (context) =>
                      const PlaceholderScreen(title: 'Help & Support'),
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
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: Colors.grey[400])
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

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(child: Text("This is the $title screen.")),
    );
  }
}

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  bool _isDarkMode = false;

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
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
                debugPrint('Theme toggled: ${_isDarkMode ? "Dark" : "Light"}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
