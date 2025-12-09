import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/image_helper.dart';
import '../../widgets/image_gallery_viewer.dart';
import 'product_form_admin_screen.dart';

class ManageProductScreen extends StatefulWidget {
  const ManageProductScreen({super.key});

  @override
  State<ManageProductScreen> createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  String searchQuery = "";

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return "-";
    final d = ts.toDate();
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year}  "
        "${d.hour.toString().padLeft(2, '0')}:"
        "${d.minute.toString().padLeft(2, '0')}";
  }

  ImageProvider getImage(dynamic raw) {
    if (raw == null) return const AssetImage("assets/placeholder.png");
    if (raw.toString().startsWith("http")) return NetworkImage(raw);
    try {
      return ImageHelper.imageFromBase64String(raw);
    } catch (_) {
      return const AssetImage("assets/placeholder.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0A1D37);
    const deepNavy = Color(0xFF081629);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // =====================================================
          // HEADER NAVY PREMIUM — SAMA PERSIS STYLE SPT USER
          // =====================================================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [navy, deepNavy],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row BACK + TITLE
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Manajemen Produk",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ================================================
                // SEARCH BAR PUTIH — SAMA PERSIS UI USER
                // ================================================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged:
                        (v) => setState(() => searchQuery = v.toLowerCase()),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Cari produk...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // =====================================================
          // LIST PRODUK
          // =====================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('products')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Terjadi kesalahan"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final filtered =
                    docs.where((d) {
                      final p = d.data() as Map<String, dynamic>;
                      return (p['name'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery);
                    }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("Produk tidak ditemukan"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final p = doc.data() as Map<String, dynamic>;

                    final img = (p['images'] as List?)?.first;
                    final name = p['name'] ?? '-';
                    final price = p['price'] ?? 0;
                    final category = p['category'] ?? '-';

                    final createdAt = _formatTimestamp(p['createdAt']);
                    final updatedAt = _formatTimestamp(p['updatedAt']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ==========================
                          // GAMBAR PRODUK - CLICKABLE
                          // ==========================
                          GestureDetector(
                            onTap: () {
                              final imageList =
                                  (p['images'] as List?)
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[300],
                                child:
                                    img != null
                                        ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image(
                                              image: getImage(img),
                                              fit: BoxFit.cover,
                                            ),
                                            if (((p['images'] as List?)
                                                        ?.length ??
                                                    0) >
                                                1)
                                              Positioned(
                                                bottom: 2,
                                                right: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '+${((p['images'] as List?)?.length ?? 1) - 1}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        )
                                        : const Icon(Icons.image, size: 32),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // ==========================
                          // INFO PRODUK
                          // ==========================
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Rp $price • $category",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Show "Dibuat" if never updated, otherwise show "Update"
                                Text(
                                  updatedAt != "-" && updatedAt != createdAt
                                      ? "Update: $updatedAt"
                                      : "Dibuat: $createdAt",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ==========================
                          // ACTION MENU
                          // ==========================
                          PopupMenuButton(
                            itemBuilder:
                                (_) => const [
                                  PopupMenuItem(
                                    value: "edit",
                                    child: Text("Edit"),
                                  ),
                                  PopupMenuItem(
                                    value: "delete",
                                    child: Text(
                                      "Hapus",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                            onSelected: (v) async {
                              if (v == "edit") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProductFormAdminScreen(
                                          product: p,
                                          productId: doc.id,
                                        ),
                                  ),
                                );
                              } else if (v == "delete") {
                                final confirm = await showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text("Hapus Produk"),
                                        content: const Text(
                                          "Hapus produk ini dari database?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Batal"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text("Hapus"),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection("products")
                                      .doc(doc.id)
                                      .delete();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // =====================================================
      // FLOATING BUTTON ADD PRODUK
      // =====================================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: navy,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormAdminScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
