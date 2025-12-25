import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../services/pdf_loader.dart';
import 'thumbnail_item.dart';

class ThumbnailGrid extends StatelessWidget {
  final AppState appState;
  final PdfLoader pdfLoader;

  const ThumbnailGrid({
    super.key,
    required this.appState,
    required this.pdfLoader,
  });

  @override
  Widget build(BuildContext context) {
    if (appState.document == null) return Container();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Header with close button
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Pages',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    appState.isThumbnailViewOpen = false;
                  },
                ),
              ],
            ),
          ),

          /// Grid of thumbnails
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns in the sidebar
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 16,
              ),
              itemCount: appState.document!.pagesCount,
              itemBuilder: (context, index) {
                return ThumbnailItem(
                  document: appState.document!,
                  pageIndex: index,
                  isSelected: appState.currentPage == index,
                  onTap: () {
                    /// Navigate to selected page
                    pdfLoader.navigateToPage(
                      index + 1,
                    ); // loader uses 1-based index
                    // Don't close the view automatically
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
