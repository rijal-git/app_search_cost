import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../../utils/image_helper.dart';
import '../../main.dart';

class ProductFormAdminScreen extends StatefulWidget {
  final Map<String, dynamic>?
  product; // If null, Add mode. If not null, Edit mode.
  final String? productId;

  const ProductFormAdminScreen({super.key, this.product, this.productId});

  @override
  State<ProductFormAdminScreen> createState() => _ProductFormAdminScreenState();
}

class _ProductFormAdminScreenState extends State<ProductFormAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _labelsCtrl = TextEditingController();
  final TextEditingController _barcodeCtrl = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;

  // Image handling
  final ImagePicker _picker = ImagePicker();
  List<XFile> _newImages = []; // Foto baru yang akan diproses
  List<String> _existingImages = []; // Foto lama (Base64 atau URL)

  final List<String> _categories = [
    "Makanan",
    "Minuman",
    "Alat Tulis",
    "Lainnya",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameCtrl.text = widget.product!['name'] ?? '';
      _priceCtrl.text = (widget.product!['price'] ?? 0).toString();
      _selectedCategory = widget.product!['category'];
      _barcodeCtrl.text = widget.product!['barcode'] ?? '';

      // Handle Labels
      final labels = widget.product!['labels'] as List?;
      if (labels != null) {
        _labelsCtrl.text = labels.join(', ');
      }

      // Handle Images
      final images = widget.product!['images'] as List?;
      if (images != null) {
        _existingImages = images.map((e) => e.toString()).toList();
      }
    }
  }

  // Show dialog to choose Camera or Gallery
  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto (Kamera)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMultiImages();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Handle Gallery (Multi)
  Future<void> _pickMultiImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          _newImages.addAll(picked);
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  // Handle Camera (Single)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _newImages.add(picked);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  // 📱 Scan Barcode
  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        setState(() {
          _barcodeCtrl.text = result.rawContent;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Barcode: ${result.rawContent}")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error scanning barcode: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 📤 Upload images to Cloudinary
  Future<List<String>> _processImages() async {
    List<String> imageUrls = [];

    for (int i = 0; i < _newImages.length; i++) {
      try {
        debugPrint("📤 Uploading image ${i + 1}/${_newImages.length}...");

        final imageFile = File(_newImages[i].path);
        final fileName =
            "${_nameCtrl.text.trim()}_${DateTime.now().millisecond}";

        final url = await cloudinaryService.uploadImage(
          imageFile,
          folder: "products",
          fileName: fileName,
        );

        if (url != null) {
          imageUrls.add(url);
          debugPrint("✅ Image uploaded: $url");
        } else {
          debugPrint("❌ Failed to upload image ${i + 1}");
        }
      } catch (e) {
        debugPrint("❌ Error uploading image ${i + 1}: $e");
      }
    }

    return imageUrls;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kategori terlebih dahulu")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload New Images to Cloudinary
      debugPrint("🚀 Starting product save...");
      List<String> newImageUrls = await _processImages();

      // Combine with existing images
      List<String> finalImages = [..._existingImages, ...newImageUrls];
      debugPrint("✅ Total images: ${finalImages.length}");

      // 2. Prepare Labels
      final labelsList =
          _labelsCtrl.text
              .split(',')
              .map((e) => e.trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toList();

      // Tambahkan nama produk dan kategori ke labels agar mudah dicari
      labelsList.add(_nameCtrl.text.trim().toLowerCase());
      if (_selectedCategory != null) {
        labelsList.add(_selectedCategory!.toLowerCase());
      }

      // 3. Prepare Data
      final data = {
        "name": _nameCtrl.text.trim(),
        "price": int.parse(_priceCtrl.text.trim()),
        "category": _selectedCategory,
        "barcode": _barcodeCtrl.text.trim(),
        "labels": labelsList,
        "images":
            finalImages, // 🎨 Now stored as Cloudinary URLs instead of Base64!
        "updatedAt": FieldValue.serverTimestamp(),
      };

      if (widget.productId == null) {
        // Create
        data["createdAt"] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('products').add(data);
      } else {
        // Update
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update(data);
      }

      if (mounted) {
        Navigator.pop(context, true); // Refresh list
      }
    } catch (e) {
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
      appBar: AppBar(
        title: Text(widget.productId == null ? "Tambah Produk" : "Edit Produk"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= IMAGE PICKER SECTION =================
              Text(
                "Foto Produk",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Tombol Add Photo
                    GestureDetector(
                      onTap: _showImageSourcePicker,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Existing Images (Handle Base64 or URL)
                    ..._existingImages.asMap().entries.map((entry) {
                      ImageProvider imageProvider;
                      if (entry.value.startsWith('http')) {
                        imageProvider = NetworkImage(entry.value);
                      } else {
                        try {
                          imageProvider = ImageHelper.imageFromBase64String(
                            entry.value,
                          );
                        } catch (e) {
                          imageProvider = const AssetImage(
                            'assets/placeholder.png',
                          ); // Fallback
                        }
                      }

                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeExistingImage(entry.key),
                              child: Container(
                                color: Colors.red,
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    // New Images (Local File)
                    ..._newImages.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(entry.value.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeNewImage(entry.key),
                              child: Container(
                                color: Colors.red,
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nama Produk",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Harga",
                  border: OutlineInputBorder(),
                  prefixText: "Rp ",
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Wajib diisi";
                  if (int.tryParse(v) == null) return "Harus angka";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items:
                    _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // BARCODE FIELD with Scan Button
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeCtrl,
                      decoration: const InputDecoration(
                        labelText: "Barcode",
                        hintText: "Scan atau ketik manual",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Scan"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _labelsCtrl,
                decoration: const InputDecoration(
                  labelText: "Labels / Kata Kunci (pisahkan koma)",
                  hintText: "Contoh: aqua, air mineral, botol",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Simpan Produk"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
