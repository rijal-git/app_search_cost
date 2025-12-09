import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/app_colors.dart';
import 'services/cloudinary_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/scan_item_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint("🚀 Starting App...");
    debugPrint("🔥 Initializing Firebase...");

    // Init Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    debugPrint("✅ Firebase Initialized successfully");

    // 🎨 Init Cloudinary
    debugPrint("📸 Initializing Cloudinary...");
    _initCloudinary();
  } catch (e) {
    debugPrint("❌ Firebase Init Error: $e");
  }

  runApp(const MyApp());
}

/// Initialize Cloudinary for image uploads
final CloudinaryService cloudinaryService = CloudinaryService(
  cloudName: "dfuobwqip",
  uploadPreset: "app_search_cost",
);

void _initCloudinary() {
  debugPrint("📸 Cloudinary initialized:");
  debugPrint("   Cloud Name: dfuobwqip");
  debugPrint("   Preset: app_search_cost");
  debugPrint("✅ Ready for image uploads!");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan Harga Barang',
      debugShowCheckedModeBanner: false, // Hilangkan banner DEBUG
      theme: getNavyGoldTheme(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/scan-item': (context) => const ScanItemScreen(),
        '/list': (context) => const ProductListScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
