import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key});

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  String searchQuery = "";

  Future<void> _deleteUser(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Hapus User?"),
            content: const Text(
              "User akan dihapus dari database admin. Login auth mungkin masih aktif.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User berhasil dihapus")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0A1D37);
    const gold3 = Color(0xFFC4873D);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // ===========================
          // HEADER NAVY PREMIUM + BACK
          // ===========================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [navy, Color(0xFF081629)],
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
                // ====== ROW BACK + TITLE ======
                Row(
                  children: [
                    // TOMBOL BACK
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
                      "Manajemen User",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ===========================
                // SEARCH BAR
                // ===========================
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
                    onChanged: (v) => setState(() => searchQuery = v),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Cari user...",
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

          // ===========================
          // LIST USER
          // ===========================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Better error display
                  String errorMsg = snapshot.error.toString();
                  bool isPermissionError = errorMsg.contains(
                    'permission-denied',
                  );

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isPermissionError
                                ? "Akses Ditolak"
                                : "Terjadi Kesalahan",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPermissionError
                                ? "Anda tidak memiliki izin untuk mengakses data pengguna.\n\n"
                                    "Pastikan:\n"
                                    "• Anda login sebagai admin\n"
                                    "• Email Anda adalah admin@test.com\n"
                                    "• Firestore rules telah diperbaharui"
                                : "Error: $errorMsg",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs =
                    snapshot.data!.docs.where((d) {
                      final user = d.data() as Map<String, dynamic>;
                      final email =
                          (user['email'] ?? "").toString().toLowerCase();
                      final username =
                          (user['username'] ?? "").toString().toLowerCase();
                      final q = searchQuery.toLowerCase();
                      return email.contains(q) || username.contains(q);
                    }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("Tidak ada user ditemukan"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final user = docs[index].data() as Map<String, dynamic>;

                    final email = user['email'] ?? "-";
                    final username = user['username'] ?? "(Tanpa username)";
                    final role = user['role'] ?? "user";

                    String dateStr = "-";
                    if (user['createdAt'] != null) {
                      final ts = user['createdAt'] as Timestamp;
                      dateStr = DateFormat(
                        "dd MMM yyyy • HH:mm",
                      ).format(ts.toDate());
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: gold3,
                            child: Icon(
                              role == "admin"
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Terdaftar: $dateStr",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          role == "admin"
                              ? const SizedBox()
                              : IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.grey[600],
                                onPressed:
                                    () => _deleteUser(context, docs[index].id),
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
