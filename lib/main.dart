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
