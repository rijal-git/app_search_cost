import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanPaymentScreen extends StatefulWidget {
  const ScanPaymentScreen({super.key});

  @override
  State<ScanPaymentScreen> createState() => _ScanPaymentScreenState();
}

class _ScanPaymentScreenState extends State<ScanPaymentScreen> {
  @override
  void initState() {
    super.initState();
    _startScanner();
  }

  Future<void> _startScanner() async {
    try {
      var result = await BarcodeScanner.scan();

      debugPrint("🔍 QR Scan Result:");
      debugPrint("   Type: ${result.type}");
      debugPrint("   Raw Content: ${result.rawContent}");
      debugPrint("   Format: ${result.format}");

      if (!mounted) return;

      // Handle barcode/QR result
      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        final url = result.rawContent.trim();

        debugPrint("📱 Processing QR: $url");

        // Parse URL
        Uri? uri;
        String qrType = "Unknown";

        try {
          // 1️⃣ Cek jenis QR code
          if (url.startsWith('https://')) {
            // QRIS atau Dana HTTP link
            qrType = "HTTP";
            uri = Uri.parse(url);
            debugPrint("✅ Detected as QRIS/HTTP link");
          } else if (url.startsWith('dana://')) {
            // Dana deep link
            qrType = "Dana";
            uri = Uri.parse(url);
            debugPrint("✅ Detected as Dana deep link");
          } else if (url.startsWith('http://')) {
            // HTTP (tidak secure tapi bisa)
            qrType = "HTTP";
            uri = Uri.parse(url);
            debugPrint("⚠️ Detected as HTTP (not secure)");
          } else {
            // Coba parse as is
            uri = Uri.parse(url);
            qrType = "Generic";
            debugPrint("⚠️ Generic QR format");
          }
        } catch (e) {
          debugPrint("❌ Failed to parse QR: $e");
          if (mounted) {
            Navigator.pop(context, null);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Format QR tidak valid"),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // 2️⃣ Coba launch URL
        bool launched = false;
        try {
          if (await canLaunchUrl(uri)) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            debugPrint("✅ URL launched successfully ($qrType)");
          } else {
            debugPrint("⚠️ Cannot launch $qrType URL");

            // Fallback: untuk QRIS, coba buka dengan browser
            if (qrType == "HTTP") {
              try {
                launched = await launchUrl(
                  uri,
                  mode: LaunchMode.platformDefault,
                );
                debugPrint("🔄 Launched with browser as fallback");
              } catch (e) {
                debugPrint("❌ Browser launch failed: $e");
              }
            }
          }
        } catch (e) {
          debugPrint("❌ Launch error: $e");
        }

        if (!mounted) return;

        // 3️⃣ Return hasil
        if (launched) {
          debugPrint("✅ QR Processing complete");
          // Return raw content jadi bisa dipanggil lagi
          Navigator.pop(context, result.rawContent);
        } else {
          debugPrint("❌ Failed to launch payment");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Gagal membuka QR ($qrType).\n"
                "Pastikan aplikasi e-wallet sudah terinstall.",
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context, null);
        }
      } else if (result.type == ResultType.Cancelled) {
        debugPrint("❌ QR scan cancelled");
        Navigator.pop(context, null);
      } else {
        debugPrint("⚠️ Invalid barcode type: ${result.type}");
        Navigator.pop(context, null);
      }
    } catch (e) {
      debugPrint("❌ Scanner error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error scanning: $e"),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Membuka Scanner...",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
