import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_search_cost/screens/scan_item_screen.dart';
import 'package:app_search_cost/screens/upload_payment_screen.dart'; // Import this
import '../utils/image_helper.dart';
import '../widgets/image_gallery_viewer.dart';
import '../config/app_colors.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _search = TextEditingController();

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> searchResult = [];
  String? selectedCategory;
  bool loading = true;

  // Helper: Scan QR Payment & Launch E-Wallet
  Future<void> _scanPaymentQR(int price, String productName) async {
    try {
      var result = await BarcodeScanner.scan();

      debugPrint("🔍 Barcode Scan Result:");
      debugPrint("   Type: ${result.type}");
      debugPrint("   Raw Content: ${result.rawContent}");
      debugPrint("   Format: ${result.format}");

      // Handle barcode result
      if (result.type == ResultType.Barcode || result.rawContent.isNotEmpty) {
        final url = result.rawContent.trim();

        if (url.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("QR code tidak valid")),
            );
          }
          return;
        }

        debugPrint("📱 Attempting to launch URL: $url");

        // 1. Parse dan validasi URL
        Uri? uri;
        try {
          // Jika bukan URL lengkap, tambahkan scheme
          if (!url.startsWith('http') && !url.startsWith('dana://')) {
            uri = Uri.parse('dana://$url');
          } else {
            uri = Uri.parse(url);
          }
        } catch (e) {
          debugPrint("❌ URL Parse Error: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Format QR code tidak valid")),
            );
          }
          return;
        }

        // 2. Cek apakah aplikasi bisa dibuka
        bool launched = false;
        try {
          // Cek apakah URL bisa diluncurkan
          if (await canLaunchUrl(uri)) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            debugPrint("✅ URL launched successfully");
          } else {
            debugPrint("⚠️ Cannot launch URL: $uri");

            // Try alternative Dana scheme
            if (url.contains('dana') || uri.scheme == 'dana') {
              debugPrint("🔄 Trying alternative Dana deep link...");
              final altUri = Uri.parse('dana://');
              if (await canLaunchUrl(altUri)) {
                launched = await launchUrl(
                  altUri,
                  mode: LaunchMode.externalApplication,
                );
              }
            }
          }
        } catch (e) {
          debugPrint("❌ Launch URL Error: $e");
          launched = false;
        }

        if (!mounted) return;

        // 3. Show result
        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Aplikasi Dana tidak terinstall atau URL tidak valid.\n"
                "Pastikan Dana sudah terinstall di device.",
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // 4. Navigate to Upload Proof (Auto-fill data)
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
      } else if (result.type == ResultType.Cancelled) {
        debugPrint("❌ Barcode scan cancelled by user");
      }
    } catch (e) {
      debugPrint("❌ QR Scan Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error scanning barcode: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadProducts();
      _applyCategoryFilter();
    });
  }

  // ======================================
  // LOAD DATA DARI FIRESTORE
  // ======================================
  Future<void> _loadProducts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      allProducts =
          snapshot.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList();

      loading = false;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error loading products: $e");
      loading = false;
      if (mounted) setState(() {});
    }
  }

  // ======================================
  // FILTER BERDASARKAN KATEGORI (from dashboard)
  // ======================================
  void _applyCategoryFilter() {
    if (!mounted) return;
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map && args.containsKey("category")) {
      selectedCategory = args["category"] as String?;

      searchResult =
          allProducts
              .where(
                (p) =>
                    (p["category"] as String?)?.toLowerCase() ==
                    selectedCategory?.toLowerCase(),
              )
              .toList();
    } else {
      searchResult = allProducts;
      selectedCategory = null;
    }

    setState(() {});
  }

  // search item
  void onSearch(String text) {
    setState(() {
      searchResult =
          allProducts.where((p) {
            final name = (p["name"] as String?) ?? "";
            final nameMatch = name.toLowerCase().contains(text.toLowerCase());

            final categoryMatch =
                selectedCategory == null || p["category"] == selectedCategory;

            return nameMatch && categoryMatch;
          }).toList();
    });
  }

  // scan barcode results
  void onScanResult(String barcode) {
    final found = allProducts.where((p) => p["barcode"] == barcode).toList();

    setState(() {
      searchResult = found;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text(
          selectedCategory ?? "Cari Harga Barang",
          style: const TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.premiumNavy,
        foregroundColor: AppColors.white,
      ),

      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _search,
                            onChanged: onSearch,
                            decoration: InputDecoration(
                              hintText: "Cari barang...",
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Scan barcode
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ScanItemScreen(),
                              ),
                            );

                            if (result != null && result is String) {
                              onScanResult(result);
                            }
                          },
                          child: Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              color: AppColors.premiumNavy,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: searchResult.length,
                      itemBuilder: (_, i) {
                        final p = searchResult[i];
                        final String name = p["name"] ?? "Tanpa Nama";
                        final int price = p["price"] ?? 0;
                        final String category = p["category"] ?? "-";

                        // Handle Image Display
                        ImageProvider? imageProvider;
                        final List? images = p["images"] as List?;
                        if (images != null && images.isNotEmpty) {
                          final firstImg = images.first.toString();
                          if (firstImg.startsWith('http')) {
                            imageProvider = NetworkImage(firstImg);
                          } else {
                            try {
                              imageProvider = ImageHelper.imageFromBase64String(
                                firstImg,
                              );
                            } catch (e) {
                              // ignore invalid base64
                            }
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  image:
                                      imageProvider != null
                                          ? DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    imageProvider == null
                                        ? const Icon(Icons.inventory_2_outlined)
                                        : Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              final imageList =
                                                  (p["images"] as List?)
                                                      ?.map((e) => e.toString())
                                                      .toList() ??
                                                  [];
                                              if (imageList.isNotEmpty) {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return ImageGalleryViewer(
                                                      imageList: imageList,
                                                      initialIndex: 0,
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            child:
                                                (images?.length ?? 0) > 1
                                                    ? Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: Container(
                                                        margin:
                                                            const EdgeInsets.all(
                                                              2,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black54,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                2,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          '+${images!.length - 1}',
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    : null,
                                          ),
                                        ),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.premiumNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Rp $price",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                    Text(
                                      "Kategori: $category",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              FilledButton(
                                onPressed: () {
                                  _scanPaymentQR(price, name);
                                },
                                child: const Text("Bayar"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
