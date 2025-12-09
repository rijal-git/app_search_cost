import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/image_helper.dart';
import '../widgets/image_gallery_viewer.dart';
import 'upload_payment_screen.dart';

class ScanItemScreen extends StatefulWidget {
  const ScanItemScreen({super.key});

  @override
  State<ScanItemScreen> createState() => _ScanItemScreenState();
}

class _ScanItemScreenState extends State<ScanItemScreen> {
  bool _isScanning = false;

  // Scan barcode barang
  Future<void> _scanBarcode() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);

    try {
      var result = await BarcodeScanner.scan();

      if (!mounted) return;

      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        final barcode = result.rawContent.trim();
        debugPrint("🔍 Scanned barcode: $barcode");

        // Cari produk di Firestore berdasarkan barcode
        await _searchProductByBarcode(barcode);
      } else if (result.type == ResultType.Cancelled) {
        debugPrint("❌ Barcode scan cancelled");
      }
    } catch (e) {
      debugPrint("❌ Scan error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error scanning: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  // Cari produk berdasarkan barcode
  Future<void> _searchProductByBarcode(String barcode) async {
    try {
      debugPrint("🔎 Searching product with barcode: $barcode");

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where('barcode', isEqualTo: barcode)
              .limit(1)
              .get();

      if (!mounted) return;

      if (querySnapshot.docs.isEmpty) {
        // Produk tidak ditemukan
        _showNotFoundDialog(barcode);
      } else {
        // Produk ditemukan
        final productDoc = querySnapshot.docs.first;
        final product = productDoc.data();
        product['id'] = productDoc.id;

        debugPrint("✅ Product found: ${product['name']}");
        _showProductDetailDialog(product);
      }
    } catch (e) {
      debugPrint("❌ Error searching product: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Dialog: Produk tidak ditemukan
  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Produk Tidak Ditemukan ❌"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Barcode: $barcode"),
                const SizedBox(height: 12),
                const Text(
                  "Produk dengan barcode ini belum terdaftar di sistem.",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  "💡 Pastikan:\n"
                  "• Barcode sudah terdaftar oleh admin\n"
                  "• Scan barcode dengan benar\n"
                  "• Coba scan ulang",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  // Dialog: Detail produk
  void _showProductDetailDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Detail Produk"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image - Clickable Gallery
                if (product['images'] != null &&
                    (product['images'] as List).isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      final images =
                          (product['images'] as List)
                              .map((e) => e.toString())
                              .toList();
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return ImageGalleryViewer(
                            imageList: images,
                            initialIndex: 0,
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 150,
                      width: double.maxFinite,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image:
                              (product['images'][0] as String).startsWith(
                                    'http',
                                  )
                                  ? NetworkImage(product['images'][0])
                                  : ImageHelper.imageFromBase64String(
                                    product['images'][0],
                                  ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child:
                          (product['images'] as List).length > 1
                              ? Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '+${(product['images'] as List).length - 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              : null,
                    ),
                  ),

                // Product Info
                Text(
                  product['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Harga: Rp ${product['price']}",
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
                const SizedBox(height: 4),
                Text("Kategori: ${product['category'] ?? '-'}"),
                const SizedBox(height: 4),
                Text(
                  "Barcode: ${product['barcode'] ?? '-'}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Kembali"),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _scanPaymentQR(
                    product['price'] ?? 0,
                    product['name'] ?? 'Produk',
                  );
                },
                child: const Text("Bayar"),
              ),
            ],
          ),
    );
  }

  // Scan QR Payment & Launch E-Wallet
  Future<void> _scanPaymentQR(int price, String productName) async {
    try {
      var result = await BarcodeScanner.scan();

      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        final url = result.rawContent.trim();

        if (url.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("QR code tidak valid")),
            );
          }
          return;
        }

        Uri? uri;
        try {
          if (!url.startsWith('http') && !url.startsWith('dana://')) {
            uri = Uri.parse('dana://$url');
          } else {
            uri = Uri.parse(url);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Format QR code tidak valid")),
            );
          }
          return;
        }

        bool launched = false;
        try {
          if (await canLaunchUrl(uri)) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          }
        } catch (e) {
          debugPrint("❌ Launch URL Error: $e");
        }

        if (!mounted) return;

        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Aplikasi Dana tidak terinstall atau URL tidak valid.",
              ),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Navigate to Upload Proof
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => UploadPaymentScreen(
                      initialAmount: price,
                      productName: productName,
                    ),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint("❌ QR Scan Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color premiumNavy = Color(0xFF0A1A2F);
    const Color goldMedium = Color(0xFFE9C678);

    return Scaffold(
      backgroundColor: premiumNavy,
      appBar: AppBar(
        title: const Text("Scan Barcode Barang"),
        backgroundColor: premiumNavy,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Barcode Icon
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 120,
                  color: goldMedium,
                ),
              ),
              const SizedBox(height: 40),

              // Instructions
              const Text(
                "Arahkan kamera ke\nbarcode barang",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Pastikan barcode terlihat jelas\ndan tidak blur",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),

              // Scan Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? null : _scanBarcode,
                  icon:
                      _isScanning
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: premiumNavy,
                            ),
                          )
                          : const Icon(Icons.qr_code_scanner, size: 28),
                  label: Text(
                    _isScanning ? "Scanning..." : "SCAN BARCODE",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldMedium,
                    foregroundColor: premiumNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: goldMedium.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.lightbulb_outline,
                          color: goldMedium,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Tips:",
                          style: TextStyle(
                            color: goldMedium,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "• Pastikan pencahayaan cukup\n"
                      "• Jaga jarak 10-15 cm dari barcode\n"
                      "• Tahan kamera tetap stabil",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
