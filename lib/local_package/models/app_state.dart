import 'package:flutter/foundation.dart';
import 'package:pdfx/pdfx.dart';
import '../services/web_fullscreen.dart';

class AppState extends ChangeNotifier {
  AppState() {
    // Listen to browser fullscreen changes (ESC key etc)
    initFullScreenListener((isFullScreen) {
      if (_isFullScreen != isFullScreen) {
        _isFullScreen = isFullScreen;
        notifyListeners();
      }
    });
  }

  /// PDF related state
  PdfDocument? _document;
  Map<int, PdfPageImage> _pageImages = {}; // Changed to Map
  List<int> _alreadyAdded = [];
  bool _isLoading = false;
  bool _showLastPage = true;
  String? _errorMessage;

  /// Navigation state
  int _currentPage = 0;
  int _currentPageComplete = 0;
  int _totalPages = 0;

  /// Animation state
  bool _animationEnd = true;
  bool _animationComplete = false;
  bool _isAnimationReady = true;
  bool _isSwipeInProgress = false;
  bool _isSwipingLeft = true;

  /// Zoom state
  bool _isZoomed = false;

  /// Mobile zoom state
  bool _isMobileZoomed = false;
  bool _isMobileZoomAnimation = false;

  /// Thumbnail view state
  bool _isThumbnailViewOpen = false;

  /// Full screen state
  bool _isFullScreen = false;

  /// Getters
  PdfDocument? get document => _document;
  Map<int, PdfPageImage> get pageImages => _pageImages; // Changed getter
  List<int> get alreadyAdded => _alreadyAdded;
  bool get isLoading => _isLoading;
  bool get showLastPage => _showLastPage;
  String? get errorMessage => _errorMessage;
  int get currentTotalPages => _totalPages;
  int get currentPage => _currentPage;
  int get currentPageComplete => _currentPageComplete;
  bool get animationEnd => _animationEnd;
  bool get animationComplete => _animationComplete;
  bool get isAnimationReady => _isAnimationReady;
  bool get isSwipeInProgress => _isSwipeInProgress;
  bool get isSwipingLeft => _isSwipingLeft;
  bool get isZoomed => _isZoomed;
  bool get isMobileZoomed => _isMobileZoomed;
  bool get isMobileZoomAnimation => _isMobileZoomAnimation;
  bool get isThumbnailViewOpen => _isThumbnailViewOpen;
  bool get isFullScreen => _isFullScreen;

  /// Platform detection
  bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Setters with notifyListeners
  set document(PdfDocument? value) {
    _document = value;
    notifyListeners();
  }

  set pageImages(Map<int, PdfPageImage> value) {
    // Changed setter
    _pageImages = value;
    notifyListeners();
  }

  set alreadyAdded(List<int> value) {
    _alreadyAdded = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set showLastPage(bool value) {
    _showLastPage = value;
    notifyListeners();
  }

  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  set currentPageComplete(int value) {
    _currentPageComplete = value;
    notifyListeners();
  }

  set animationEnd(bool value) {
    _animationEnd = value;
    notifyListeners();
  }

  set animationComplete(bool value) {
    _animationComplete = value;
    notifyListeners();
  }

  set isAnimationReady(bool value) {
    _isAnimationReady = value;
    notifyListeners();
  }

  set isSwipeInProgress(bool value) {
    _isSwipeInProgress = value;
    notifyListeners();
  }

  set isSwipingLeft(bool value) {
    _isSwipingLeft = value;
    notifyListeners();
  }

  set isZoomed(bool value) {
    _isZoomed = value;
    notifyListeners();
  }

  set isMobileZoomed(bool value) {
    _isMobileZoomed = value;
    notifyListeners();
  }

  set isMobileZoomAnimation(bool value) {
    _isMobileZoomAnimation = value;
    notifyListeners();
  }

  set isThumbnailViewOpen(bool value) {
    _isThumbnailViewOpen = value;
    notifyListeners();
  }

  set isFullScreen(bool value) {
    _isFullScreen = value;
    notifyListeners();
  }

  set totalPages(int value) {
    _totalPages = value;
    notifyListeners();
  }

  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  /// Mobile zoom control methods
  void toggleMobileZoom() {
    if (!isMobile) return;

    isMobileZoomAnimation = true;
    isMobileZoomed = !isMobileZoomed;

    /// Reset animation after a delay
    Future.delayed(Duration(milliseconds: 300), () {
      isMobileZoomAnimation = false;
    });
  }

  void resetMobileZoom() {
    if (!isMobile) return;
    isMobileZoomed = false;
    isMobileZoomAnimation = false;
  }

  /// Full screen control method
  void toggleFullScreen() {
    print('AppState: toggleFullScreen called. Current: $_isFullScreen');
    isFullScreen = !isFullScreen;

    // Call web implementation (stubbed on mobile)
    toggleWebFullScreen(_isFullScreen);

    print('AppState: toggleFullScreen new state: $_isFullScreen');
  }

  /// Batch update method for multiple state changes
  void updateMultiple({
    bool? animationEnd,
    bool? animationComplete,
    bool? isAnimationReady,
    bool? isSwipeInProgress,
    bool? isSwipingLeft,
    int? currentPage,
    int? currentPageComplete,
  }) {
    bool shouldNotify = false;

    if (animationEnd != null && _animationEnd != animationEnd) {
      _animationEnd = animationEnd;
      shouldNotify = true;
    }
    if (animationComplete != null && _animationComplete != animationComplete) {
      _animationComplete = animationComplete;
      shouldNotify = true;
    }
    if (isAnimationReady != null && _isAnimationReady != isAnimationReady) {
      _isAnimationReady = isAnimationReady;
      shouldNotify = true;
    }
    if (isSwipeInProgress != null && _isSwipeInProgress != isSwipeInProgress) {
      _isSwipeInProgress = isSwipeInProgress;
      shouldNotify = true;
    }
    if (isSwipingLeft != null && _isSwipingLeft != isSwipingLeft) {
      _isSwipingLeft = isSwipingLeft;
      shouldNotify = true;
    }
    if (currentPage != null && _currentPage != currentPage) {
      _currentPage = currentPage;
      shouldNotify = true;
    }
    if (currentPageComplete != null &&
        _currentPageComplete != currentPageComplete) {
      _currentPageComplete = currentPageComplete;
      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  /// Clear all state
  void clear() {
    _document = null;
    _pageImages = {}; // Clear map
    _alreadyAdded.clear();
    _isLoading = false;
    _showLastPage = true;
    _currentPage = 0;
    _currentPageComplete = 0;
    _animationEnd = true;
    _animationComplete = false;
    _isAnimationReady = true;
    _isSwipeInProgress = false;
    _isSwipingLeft = true;
    _isZoomed = false;
    _isMobileZoomed = false;
    _isMobileZoomAnimation = false;
    _isFullScreen = false;
    _errorMessage = null;
    notifyListeners();
  }
}
