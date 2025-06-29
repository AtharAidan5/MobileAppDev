import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'upload_screen.dart';
import 'create_certificate_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'services/storage_service.dart';
import 'services/pdf_storage_service.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: CertifyAppRouter(),
    ),
  );
}

class UserProvider extends ChangeNotifier {
  User? user;
  String? role;
  final AuthService _authService = AuthService();

  Future<void> loadUser() async {
    user = _authService.currentUser;
    if (user != null) {
      role = await _authService.getUserRole(user!.uid);
    }
    notifyListeners();
  }

  void clear() {
    user = null;
    role = null;
    notifyListeners();
  }
}

class CertifyAppRouter extends StatelessWidget {
  CertifyAppRouter({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGate(),
        routes: [
          GoRoute(
            path: 'view/:token',
            builder: (context, state) {
              final token = state.pathParameters['token']!;
              return CertificateViewerScreen(token: token);
            },
          ),
        ],
      ),
    ],
    initialLocation: '/',
    debugLogDiagnostics: true,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp.router(
          title: 'Certify App',
          debugShowCheckedModeBanner: false,
          theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          routerConfig: _router,
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Load user role and show loading screen
        return FutureBuilder<void>(
          future: Provider.of<UserProvider>(context, listen: false).loadUser(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading user role...'),
                    ],
                  ),
                ),
              );
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService().signInWithGoogle();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Certify App',
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google (UPM only)'),
                onPressed: _loading ? null : _handleGoogleSignIn,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
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
    final userProvider = Provider.of<UserProvider>(context);
    final role = userProvider.role;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Debug logging
    print('DEBUG: Current role: $role');
    print('DEBUG: User: ${userProvider.user?.email}');

    // Define screens and nav items - static list for all users
    final List<Widget> screens = [
      // Remove const to allow conditional items
      const DashboardScreen(), // Index 0
      const CertificatesScreen(), // Index 1
      if (role == 'admin' || role == 'ca')
        const ApprovalScreen(), // Index 2 (conditional)
      const SettingsScreen(), // Index 3 (or 2 if no approval)
      const ProfileScreen(), // Index 4 (or 3 if no approval)
    ];

    // Define the EXACT navigation items for the bottom navigation bar.
    // The order and number of items here MUST match the 'screens' list above.
    final List<Map<String, dynamic>> navItems = [
      // Remove const to allow conditional items
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.article_outlined, 'label': 'Certificates'},
      if (role == 'admin' || role == 'ca')
        {'icon': Icons.verified, 'label': 'Approvals'},
      {'icon': Icons.settings_outlined, 'label': 'Settings'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    print('DEBUG: Number of nav items: ${navItems.length}');
    print(
        'DEBUG: Admin nav item exists: ${navItems.any((item) => item['label'] == 'Admin')}');

    // Guard index
    int safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

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
          screens[safeIndex],
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = safeIndex == index;
                final color = isSelected
                    ? (isDark ? Colors.blue[300] : Colors.blue[700])
                    : (isDark ? Colors.grey[400] : Colors.grey[600]);
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? Colors.blue[900]?.withOpacity(0.2)
                              : Colors.blue[50])
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item['icon'], color: color, size: 20),
                        const SizedBox(height: 2),
                        Text(
                          item['label'],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: color,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
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
                ).then((result) {
                  // Certificate created successfully - no need to refresh since data streams will update automatically
                  if (result == true) {
                    print('DEBUG: Certificate created successfully');
                  }
                }),
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
              if (Provider.of<UserProvider>(context, listen: false).role ==
                      'admin' ||
                  Provider.of<UserProvider>(context, listen: false).role ==
                      'ca')
                _buildActionCard(
                  context,
                  Icons.verified,
                  'Approvals',
                  const Color(0xFFFF6B6B),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApprovalScreen(),
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

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  Map<String, String> _lastStatuses = {};

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
        // Check for status changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final doc in docs) {
            final certId = doc.id;
            final status = doc['status'] ?? '';
            if (_lastStatuses.containsKey(certId) &&
                _lastStatuses[certId] != status) {
              if (status == 'approved' || status == 'rejected') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Certificate "${doc['name']}" was $status.'),
                    backgroundColor:
                        status == 'approved' ? Colors.green : Colors.red,
                  ),
                );
              }
            }
            _lastStatuses[certId] = status;
          }
        });
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final shareToken = data['shareToken'] ?? '';
            final certId = docs[index].id;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Icon(Icons.verified,
                    color: Theme.of(context).colorScheme.primary),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(data['name'] ?? 'No Name'),
                    ),
                    if (data['pdfBase64'] != null)
                      Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red[600],
                        size: 20,
                      ),
                  ],
                ),
                subtitle: Text(
                  'Recipient: ${data['recipient'] ?? ''}\nOrganization: ${data['organization'] ?? ''}\nStatus: ${data['status'] ?? 'unknown'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data['pdfBase64'] != null)
                      IconButton(
                        icon: const Icon(Icons.download),
                        tooltip: 'Download PDF',
                        onPressed: () async {
                          final pdfStorageService = PdfStorageService();
                          final pdfBase64 = data['pdfBase64'] as String;
                          final fileName =
                              'certificate_${data['name']}_${DateTime.now().millisecondsSinceEpoch}.pdf';

                          try {
                            final file = await pdfStorageService.savePdfToFile(
                                pdfBase64, fileName);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('PDF saved to: ${file.path}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save PDF: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: 'Share',
                      onPressed: () async {
                        final url = 'https://yourapp.com/view/$shareToken';
                        await Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Share link copied!')),
                        );
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CertificateViewerScreen(token: shareToken),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class CertificateViewerScreen extends StatefulWidget {
  final String token;
  const CertificateViewerScreen({super.key, required this.token});

  @override
  State<CertificateViewerScreen> createState() =>
      _CertificateViewerScreenState();
}

class _CertificateViewerScreenState extends State<CertificateViewerScreen> {
  Future<void> _viewPdf(String pdfBase64, String certificateName) async {
    try {
      final pdfStorageService = PdfStorageService();
      final fileName =
          'certificate_${certificateName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = await pdfStorageService.savePdfToFile(pdfBase64, fileName);

      // Navigate to PDF viewer screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PDFViewerScreen(pdfPath: file.path, title: certificateName),
        ),
      );
    } catch (e) {
      // Fallback to external viewer
      try {
        final pdfStorageService = PdfStorageService();
        final dataUrl = pdfStorageService.createDataUrl(pdfBase64);
        final uri = Uri.parse(dataUrl);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('No PDF viewer available');
        }
      } catch (fallbackError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open PDF: $fallbackError'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(String pdfBase64, String certificateName) async {
    try {
      final pdfStorageService = PdfStorageService();
      final fileName =
          'certificate_${certificateName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = await pdfStorageService.savePdfToFile(pdfBase64, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved to: ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return FutureBuilder(
      future: FirestoreService().getCertificateByToken(widget.token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: const Center(child: Text('Certificate not found.')),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final certId = snapshot.data!.id;
        // Log view action
        FirestoreService().logCertificateAction(
          certId: certId,
          action: 'view',
          userEmail: userProvider.user?.email ?? 'anonymous',
        );
        return Scaffold(
          appBar: AppBar(
            title: Text('Certificate Viewer',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.95,
                ),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Name:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(data['name'] ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 8),
                    Text('Recipient:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(data['recipient'] ?? '',
                        style:
                            GoogleFonts.inter(fontSize: 14, color: textColor)),
                    const SizedBox(height: 6),
                    Text('Organization:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(data['organization'] ?? '',
                        style:
                            GoogleFonts.inter(fontSize: 14, color: textColor)),
                    const SizedBox(height: 6),
                    Text('Purpose:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(data['purpose'] ?? '',
                        style:
                            GoogleFonts.inter(fontSize: 14, color: textColor)),
                    const SizedBox(height: 6),
                    Text('Issued:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(
                        data['issuedDate'] != null
                            ? (data['issuedDate'] as Timestamp)
                                .toDate()
                                .toString()
                                .split(' ')
                                .first
                            : '',
                        style:
                            GoogleFonts.inter(fontSize: 14, color: textColor)),
                    const SizedBox(height: 6),
                    Text('Expiry:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(
                        data['expiryDate'] != null
                            ? (data['expiryDate'] as Timestamp)
                                .toDate()
                                .toString()
                                .split(' ')
                                .first
                            : '',
                        style:
                            GoogleFonts.inter(fontSize: 14, color: textColor)),
                    const SizedBox(height: 6),
                    Text('Status:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(data['status'] ?? '',
                        style:
                            GoogleFonts.inter(fontSize: 14, color: textColor)),
                    const SizedBox(height: 6),
                    Text('Approver:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(data['approver'] ?? '',
                        style:
                            GoogleFonts.inter(fontSize: 14, color: textColor)),
                    const SizedBox(height: 6),
                    Text('Approval Date:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(
                        data['approvalDate'] != null
                            ? (data['approvalDate'] as Timestamp)
                                .toDate()
                                .toString()
                                .split(' ')
                                .first
                            : '',
                        style:
                            GoogleFonts.inter(fontSize: 14, color: textColor)),
                    const SizedBox(height: 12),
                    Divider(color: borderColor),
                    const SizedBox(height: 12),
                    Text('Signature:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    Text(data['signature'] ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: textColor)),

                    // PDF Section
                    const SizedBox(height: 12),
                    Divider(color: borderColor),
                    const SizedBox(height: 12),
                    Text('PDF Certificate:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 8),

                    if (data['pdfBase64'] != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PDF Available',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'Certificate PDF has been generated',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Use column layout for narrow screens, row for wider screens
                          if (constraints.maxWidth < 400) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.download),
                                    label: const Text('Download PDF'),
                                    onPressed: () async {
                                      await _downloadPdf(
                                          data['pdfBase64'] as String,
                                          data['name'] ?? '');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[600],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('View PDF'),
                                    onPressed: () async {
                                      await _viewPdf(
                                          data['pdfBase64'] as String,
                                          data['name'] ?? '');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.download),
                                    label: const Text('Download PDF'),
                                    onPressed: () async {
                                      await _downloadPdf(
                                          data['pdfBase64'] as String,
                                          data['name'] ?? '');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[600],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('View PDF'),
                                    onPressed: () async {
                                      await _viewPdf(
                                          data['pdfBase64'] as String,
                                          data['name'] ?? '');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_outlined,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PDF Not Available',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'PDF generation is in progress or disabled',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Generate PDF Now'),
                          onPressed: () async {
                            // Show loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Generating PDF...'),
                                backgroundColor: Colors.blue,
                              ),
                            );

                            try {
                              // Generate PDF for this certificate
                              final pdfStorageService = PdfStorageService();
                              final pdfBase64 = await pdfStorageService
                                  .generateAndEncodePdf(data);

                              // Update Firestore
                              await FirestoreService().updateCertificatePdfData(
                                  data['shareToken'] as String, pdfBase64);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('PDF generated successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Refresh the screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CertificateViewerScreen(
                                      token: widget.token),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to generate PDF: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.pdfPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              try {
                await Share.shareFiles([pdfPath],
                    text: 'Certificate PDF: $title');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to share PDF: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        defaultPage: 0,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        onRender: (pages) {
          // PDF rendered successfully
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading PDF: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onPageError: (page, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading page $page: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.white;
    final currentUser = AuthService().currentUser;

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

          // Debug Section - Show UID
          if (currentUser != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Info',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your UID: ${currentUser.uid}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return Text(
                        'Your Role: ${userProvider.role ?? 'Loading...'}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.blue[600],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Copy this UID to create admin user',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.blue[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          _buildProfileButton(
            context,
            Icons.edit_outlined,
            'Edit Profile',
            () {},
          ),
          const SizedBox(height: 12),
          _buildProfileButton(
            context,
            Icons.admin_panel_settings,
            'Admin Setup',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminSetupScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildProfileButton(
            context,
            Icons.refresh,
            'Refresh Role',
            () async {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              await userProvider.loadUser();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Role refreshed: ${userProvider.role ?? 'No role'}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
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

// Admin Panel Screen
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final email = user['email'] ?? '';
              final role = user['role'] ?? 'recipient';
              final lastLogin = user['lastLogin'] as Timestamp?;
              final createdAt = user['createdAt'] as Timestamp?;

              String lastLoginText = 'Never';
              if (lastLogin != null) {
                final now = DateTime.now();
                final difference = now.difference(lastLogin.toDate());
                if (difference.inDays > 0) {
                  lastLoginText = '${difference.inDays} days ago';
                } else if (difference.inHours > 0) {
                  lastLoginText = '${difference.inHours} hours ago';
                } else if (difference.inMinutes > 0) {
                  lastLoginText = '${difference.inMinutes} minutes ago';
                } else {
                  lastLoginText = 'Just now';
                }
              }

              String createdAtText = 'Unknown';
              if (createdAt != null) {
                createdAtText =
                    '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}';
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(email),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role: $role'),
                      Text('Created: $createdAtText'),
                      Text('Last Login: $lastLoginText'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      await AuthService().setUserRole(user.id, value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'admin', child: Text('Admin')),
                      const PopupMenuItem(value: 'ca', child: Text('CA')),
                      const PopupMenuItem(
                          value: 'recipient', child: Text('Recipient')),
                    ],
                    child: const Icon(Icons.edit),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// CA Approval Screen
class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final approver = userProvider.user?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Approvals',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder(
        stream: FirestoreService().getPendingCertificates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending certificates.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final certId = docs[index].id;
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? 'No Name',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Recipient: ${data['recipient'] ?? ''}',
                          style: GoogleFonts.inter(fontSize: 16)),
                      Text('Organization: ${data['organization'] ?? ''}',
                          style: GoogleFonts.inter(fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              await FirestoreService().updateCertificateStatus(
                                  certId, 'approved',
                                  approver: approver);
                              await FirestoreService().logCertificateAction(
                                certId: certId,
                                action: 'approve',
                                userEmail: approver,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Certificate approved.')));
                            },
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              await FirestoreService().updateCertificateStatus(
                                  certId, 'rejected',
                                  approver: approver);
                              await FirestoreService().logCertificateAction(
                                certId: certId,
                                action: 'reject',
                                userEmail: approver,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Certificate rejected.')));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Admin Setup Screen - For manually creating admin users
class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _useUid = false; // Toggle between UID and email-only mode

  @override
  void initState() {
    super.initState();
    _roleController.text = 'admin'; // Default role
  }

  @override
  void dispose() {
    _uidController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _createAdminUser() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _message = 'Please enter an email address';
      });
      return;
    }

    if (_useUid && _uidController.text.isEmpty) {
      setState(() {
        _message = 'Please enter a UID when using UID mode';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      String uid;
      if (_useUid) {
        // Use provided UID
        await AuthService().createAdminUser(
          uid: _uidController.text.trim(),
          email: _emailController.text.trim(),
          role: _roleController.text.trim(),
        );
        uid = _uidController.text.trim();
      } else {
        // Auto-generate UID
        uid = await AuthService().createAdminUserWithEmail(
          email: _emailController.text.trim(),
          role: _roleController.text.trim(),
        );
      }

      setState(() {
        _message = 'Admin user created successfully!\nGenerated UID: $uid';
        if (!_useUid) {
          _uidController.text = uid; // Show the generated UID
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _linkCurrentUser() async {
    try {
      await AuthService().linkCurrentUserToAdmin();
      setState(() {
        _message = 'Current user linked to admin successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Admin User',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manually create admin users in Firestore',
              style: GoogleFonts.inter(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Mode Toggle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Creation Mode',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _useUid = false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: !_useUid
                                  ? (isDark
                                      ? Colors.blue[600]
                                      : Colors.blue[500])
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !_useUid
                                    ? (isDark
                                        ? Colors.blue[400]!
                                        : Colors.blue[600]!)
                                    : borderColor,
                              ),
                            ),
                            child: Text(
                              'Auto-Generate UID',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: !_useUid ? Colors.white : textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _useUid = true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _useUid
                                  ? (isDark
                                      ? Colors.blue[600]
                                      : Colors.blue[500])
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _useUid
                                    ? (isDark
                                        ? Colors.blue[400]!
                                        : Colors.blue[600]!)
                                    : borderColor,
                              ),
                            ),
                            child: Text(
                              'Use Existing UID',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: _useUid ? Colors.white : textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // UID Field (only show if using UID mode)
            if (_useUid) ...[
              Text(
                'User UID (from Firebase Auth)',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _uidController,
                style: GoogleFonts.inter(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Enter Firebase Auth UID',
                  hintStyle: GoogleFonts.inter(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.blue[300]! : Colors.blue[700]!,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Email Field
            Text(
              'Email Address',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              style: GoogleFonts.inter(color: textColor),
              decoration: InputDecoration(
                hintText: 'Enter email address',
                hintStyle: GoogleFonts.inter(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.blue[300]! : Colors.blue[700]!,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),

            // Role Field
            Text(
              'Role',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _roleController,
              style: GoogleFonts.inter(color: textColor),
              decoration: InputDecoration(
                hintText: 'admin, ca, or recipient',
                hintStyle: GoogleFonts.inter(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.blue[300]! : Colors.blue[700]!,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
              ),
            ),
            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _createAdminUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.blue[600] : Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _useUid
                            ? 'Create Admin User'
                            : 'Create Admin User (Auto UID)',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Link Current User Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _linkCurrentUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? Colors.green[600] : Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Link Current User to Admin',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            // Message Display
            if (_message != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _message!.contains('Error')
                      ? Colors.red[100]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _message!.contains('Error')
                        ? Colors.red[300]!
                        : Colors.green[300]!,
                  ),
                ),
                child: Text(
                  _message!,
                  style: GoogleFonts.inter(
                    color: _message!.contains('Error')
                        ? Colors.red[800]
                        : Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
