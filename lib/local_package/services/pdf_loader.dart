import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import '../models/app_state.dart';

class PdfLoader {
  final AppState appState;
  final String? proxyUrl;

  PdfLoader(this.appState, {this.proxyUrl});

  Future<Uint8List> fetchPdfAsBytes(String url) async {
    // Step 1: Try direct fetch first
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      } else {
        throw Exception(
          'Direct fetch failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Direct fetch failed, try proxy if available
      if (proxyUrl != null && proxyUrl!.isNotEmpty) {
        try {
          final fullProxyUrl = '$proxyUrl${Uri.encodeComponent(url)}';
          final response = await http.get(Uri.parse(fullProxyUrl));
          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            return response.bodyBytes;
          } else {
            throw Exception(
              'Proxy fetch failed with status: ${response.statusCode}',
            );
          }
        } catch (proxyError) {
          throw Exception(
            'Both direct fetch and proxy fetch failed. Direct error: $e, Proxy error: $proxyError',
          );
        }
      } else {
        throw Exception(
          'Direct fetch failed and no proxy URL provided. Error: $e',
        );
      }
    }
  }

  Future<void> loadPdf(String url) async {
    try {
      appState.isLoading = true;

      /// Download PDF as bytes
      final bytes = await fetchPdfAsBytes(url);

      if (bytes.isEmpty) {
        throw Exception("PDF file is empty or could not be downloaded.");
      }

      /// Validate PDF format by checking magic bytes
      if (bytes.length < 4 ||
          !(bytes[0] == 0x25 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x44 &&
              bytes[3] == 0x46)) {
        throw Exception(
          "Invalid PDF format. File does not appear to be a valid PDF.",
        );
      }

      /// Open PDF document
      final document = await PdfDocument.openData(bytes);

      if (document.pagesCount == 0) {
        throw Exception("PDF document has no pages.");
      }

      /// Save in your app state
      appState.document = document;
      appState.totalPages = document.pagesCount;
      appState.isLoading = false;

      /// Load initial pages
      await loadPages(0, null);
    } catch (e) {
      appState.isLoading = false;
      throw Exception("Failed to load PDF: $e");
    }
  }

  Future<void> loadPages(int index, int? pageNumber) async {
    if (appState.isLoading || appState.document == null) return;

    appState.isLoading = true;

    try {
      int pagesToLoad;

      // Simple prefetch logic: Load current + next few pages
      // For jump/setup (pageNumber != null), load a buffer around target
      // For general scrolling (pageNumber == null), load current + buffer
      int startIndex = index;

      if (pageNumber == null) {
        if (index == 0 || index == 1) {
          pagesToLoad = 6;
        } else {
          // For sequential loading, just try to load next 4
          pagesToLoad = 4;
        }
      } else {
        pagesToLoad = 4;
      }

      int endIndex = startIndex + pagesToLoad;
      if (endIndex > appState.document!.pagesCount) {
        endIndex = appState.document!.pagesCount;
      }

      for (int i = startIndex; i < endIndex; i++) {
        if (appState.alreadyAdded.any((element) => element == i)) {
          continue;
        }

        final newAlreadyAdded = List<int>.from(appState.alreadyAdded);
        newAlreadyAdded.add(i);
        appState.alreadyAdded = newAlreadyAdded;

        final page = await appState.document!.getPage(i + 1);

        /// Render at much higher resolution for better quality
        final image = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.png,
          quality: 100,
          forPrint: true,
        );

        if (image != null) {
          final newPageImages = Map<int, PdfPageImage>.from(
            appState.pageImages,
          );
          newPageImages[i] = image;

          appState.pageImages = newPageImages;
        }

        await page.close();
      }

      appState.animationComplete = false;

      // Ensure we verify update
      if (pageNumber != null) {
        // No need to set currentPage here, navigateToPage does it,
        // but safe to ensure consistency if reused.
        // But for jump, navigateToPage handles it.
      }
    } finally {
      appState.isLoading = false;
    }
  }

  Future<void> navigateToPage(int pageNumber) async {
    if (appState.document == null) return;

    if (pageNumber < 1 || pageNumber > appState.document!.pagesCount) {
      return;
    }

    /// Calculate target index (0-based)
    int targetIndex = pageNumber - 1;

    /// We do NOT clear existing pages blindly anymore,
    /// as we want to keep what we have for smooth functioning if possible.
    /// Or if we want to save memory, we clear.
    /// For now, let's keep it simple: Ensure the target page is loaded.

    // appState.pageImages = []; // Don't clear!
    // appState.alreadyAdded = [];

    /// Load the target page
    await loadPages(targetIndex, pageNumber);

    /// Update current page tracking
    appState.currentPage = targetIndex;
    appState.currentPageComplete = targetIndex;
  }
}
