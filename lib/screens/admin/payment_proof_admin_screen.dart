import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/image_helper.dart';
import '../../widgets/image_gallery_viewer.dart';

class PaymentProofAdminScreen extends StatelessWidget {
  const PaymentProofAdminScreen({super.key});

  void _showImageDialog(BuildContext context, List<String> imageSources) {
    // Show image gallery with swipe support
    showDialog(
      context: context,
      builder: (ctx) {
        return ImageGalleryViewer(imageList: imageSources, initialIndex: 0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color premiumNavy = Color(0xFF0A1A2F);
    const Color softNavy = Color(0xFF153354);
    const Color goldMedium = Color(0xFFE9C678);

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          // ================================
          // HEADER NAVY PREMIUM (CUSTOM APPBAR)
          // ================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            decoration: const BoxDecoration(
              color: premiumNavy,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child: Row(
              children: [
                // Tombol back
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 12),

                const Text(
                  "Bukti Transfer Masuk",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          // ================================
          // LIST DATA
          // ================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('payments')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.docs;
                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada bukti transfer",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = data[index].data() as Map<String, dynamic>;

                    final email = item['email'] ?? "-";
                    final amount = item['amount'] ?? 0;
                    final note = item['note'] ?? "";

                    // Support both new (imageUrl) and legacy (imageBase64)
                    final imageUrl = item['imageUrl'];
                    final imageBase64 = item['imageBase64'];
                    final imageSource = imageUrl ?? imageBase64 ?? "";

                    String dateStr = "-";
                    if (item['createdAt'] != null) {
                      dateStr = DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format((item['createdAt'] as Timestamp).toDate());
                    }

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: goldMedium, width: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail
                          GestureDetector(
                            onTap:
                                () => _showImageDialog(context, [imageSource]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child:
                                    imageSource.isNotEmpty
                                        ? imageSource.startsWith('http')
                                            ? Image.network(
                                              imageSource,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return const Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                );
                                              },
                                            )
                                            : Image(
                                              image:
                                                  ImageHelper.imageFromBase64String(
                                                    imageSource,
                                                  ),
                                              fit: BoxFit.cover,
                                            )
                                        : const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Rp ${NumberFormat('#,###').format(amount)}",
                                  style: const TextStyle(
                                    color: softNavy,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),

                                if (note.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "Catatan: $note",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 6),

                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}
