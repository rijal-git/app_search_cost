import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class UploadPaymentScreen extends StatefulWidget {
  final int? initialAmount;
  final String? productName;

  const UploadPaymentScreen({super.key, this.initialAmount, this.productName});

  @override
  State<UploadPaymentScreen> createState() => _UploadPaymentScreenState();
}

class _UploadPaymentScreenState extends State<UploadPaymentScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountCtrl.text = widget.initialAmount.toString();
    }
    if (widget.productName != null) {
      _noteCtrl.text = "Pembayaran untuk ${widget.productName}";
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _uploadProof() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih foto bukti transfer")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      debugPrint("🚀 Starting payment proof upload...");

      // 1. Upload Image to Cloudinary
      debugPrint("📤 Uploading to Cloudinary...");
      final imageUrl = await cloudinaryService.uploadImage(
        _imageFile!,
        folder: "payment_proofs",
        fileName: "proof_${user.uid}_${DateTime.now().millisecond}",
      );

      if (imageUrl == null) {
        throw Exception("Gagal upload foto ke Cloudinary");
      }

      debugPrint("✅ Image uploaded: $imageUrl");

      // 2. Save Data to Firestore with Cloudinary URL
      debugPrint("💾 Saving to Firestore...");
      await FirebaseFirestore.instance.collection('payments').add({
        'uid': user.uid,
        'email': user.email,
        'imageUrl':
            imageUrl, // 🎨 Now stored as Cloudinary URL instead of Base64!
        'amount': int.tryParse(_amountCtrl.text) ?? 0,
        'note': _noteCtrl.text.trim(),
        'status': 'pending', // pending, approved, rejected
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Payment proof saved successfully");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bukti transfer berhasil dikirim!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Bukti Transfer")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Picker Area
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder:
                      (ctx) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text("Galeri"),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text("Kamera"),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                      ),
                );
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                  image:
                      _imageFile != null
                          ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                alignment: Alignment.center,
                child:
                    _imageFile == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text("Tap untuk ambil foto"),
                          ],
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              readOnly: widget.initialAmount != null, // Lock if auto-filled
              decoration: const InputDecoration(
                labelText: "Nominal Transfer",
                prefixText: "Rp ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Catatan (Opsional)",
                hintText: "Contoh: Pembayaran Order #123",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _isLoading ? null : _uploadProof,
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Kirim Bukti"),
            ),
          ],
        ),
      ),
    );
  }
}
