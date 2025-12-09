import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class ImageGalleryViewer extends StatefulWidget {
  final List<String> imageList; // URLs atau Base64 strings
  final int initialIndex;

  const ImageGalleryViewer({
    super.key,
    required this.imageList,
    this.initialIndex = 0,
  });

  @override
  State<ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<ImageGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  ImageProvider _getImageProvider(String imageSource) {
    if (imageSource.startsWith('http')) {
      return NetworkImage(imageSource);
    } else {
      try {
        return ImageHelper.imageFromBase64String(imageSource);
      } catch (e) {
        debugPrint("Error loading image: $e");
        return const AssetImage('assets/placeholder.png');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.95),
      insetPadding: const EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // =============== Top Bar ===============
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Counter
                Text(
                  "${_currentIndex + 1} / ${widget.imageList.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          // =============== Image Carousel ===============
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.imageList.length,
              itemBuilder: (context, index) {
                final imageSource = widget.imageList[index];
                return GestureDetector(
                  onLongPress: () {
                    // Show info
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          imageSource.startsWith('http')
                              ? 'Cloudinary URL'
                              : 'Local Image',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Container(
                      color: Colors.black87,
                      child:
                          imageSource.isNotEmpty
                              ? Image(
                                image: _getImageProvider(imageSource),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.broken_image,
                                        size: 80,
                                        color: Colors.white54,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Gambar tidak bisa dimuat',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                              : const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.white54,
                                ),
                              ),
                    ),
                  ),
                );
              },
            ),
          ),

          // =============== Bottom Navigation ===============
          if (widget.imageList.length > 1)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  GestureDetector(
                    onTap:
                        _currentIndex > 0
                            ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _currentIndex > 0 ? Colors.white24 : Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color:
                            _currentIndex > 0 ? Colors.white : Colors.white38,
                        size: 28,
                      ),
                    ),
                  ),

                  // Dots indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.imageList.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              index == _currentIndex
                                  ? Colors.white
                                  : Colors.white38,
                        ),
                      ),
                    ),
                  ),

                  // Next button
                  GestureDetector(
                    onTap:
                        _currentIndex < widget.imageList.length - 1
                            ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _currentIndex < widget.imageList.length - 1
                                ? Colors.white24
                                : Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color:
                            _currentIndex < widget.imageList.length - 1
                                ? Colors.white
                                : Colors.white38,
                        size: 28,
                      ),
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
