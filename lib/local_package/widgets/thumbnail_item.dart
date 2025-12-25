import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class ThumbnailItem extends StatefulWidget {
  final PdfDocument document;
  final int pageIndex;
  final VoidCallback onTap;
  final bool isSelected;

  const ThumbnailItem({
    super.key,
    required this.document,
    required this.pageIndex,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<ThumbnailItem> createState() => _ThumbnailItemState();
}

class _ThumbnailItemState extends State<ThumbnailItem> {
  PdfPageImage? _pageImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    try {
      final page = await widget.document.getPage(widget.pageIndex + 1);

      /// Render at low resolution for thumbnails
      final image = await page.render(
        width: 150,
        height: 200, // Approximate height, aspect ratio will be preserved
        format: PdfPageImageFormat.png,
        quality: 80,
      );

      await page.close();

      if (mounted) {
        setState(() {
          _pageImage = image;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading thumbnail for page ${widget.pageIndex}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: widget.isSelected
                    ? Border.all(color: Colors.blue, width: 3)
                    : Border.all(color: Colors.grey.shade300),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _pageImage != null
                  ? Image.memory(_pageImage!.bytes, fit: BoxFit.contain)
                  : const Center(
                      child: Icon(Icons.error_outline, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Page ${widget.pageIndex + 1}',
            style: TextStyle(
              color: widget.isSelected ? Colors.blue : Colors.black87,
              fontWeight: widget.isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
