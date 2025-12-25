import 'package:flutter/material.dart';
import '../models/app_state.dart';
import 'book_animation_controller.dart';

class PageNavigation {
  final AppState appState;
  final BookAnimationController animationController;

  PageNavigation({required this.appState, required this.animationController});

  double _dragStartX = 0.0;
  double _currentDragX = 0.0;

  void handleHorizontalDragStart(DragStartDetails details) {
    if (appState.isZoomed || appState.isSwipeInProgress) return;
    _dragStartX = details.localPosition.dx;
    _currentDragX = _dragStartX;
  }

  void handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (appState.isZoomed || appState.isSwipeInProgress) return;
    _currentDragX = details.localPosition.dx;
  }

  void handleHorizontalDragEnd(DragEndDetails details) {
    if (appState.isZoomed || appState.isSwipeInProgress) return;

    final double dragDistance = _currentDragX - _dragStartX;
    final double velocity = details.primaryVelocity ?? 0.0;

    // Thresholds
    const double minDistance = 50.0;
    const double minVelocity = 300.0;

    bool shouldFlip = false;

    // Check if valid swipe
    if (dragDistance.abs() > minDistance || velocity.abs() > minVelocity) {
      // Ensure direction matches distance (unless velocity is very strong in opposite, which is rare)
      if (dragDistance < 0) {
        // Swipe Left -> Next Page
        shouldFlip = true;
        // Verify we aren't trying to go past last page
        if (!canNavigate(true)) shouldFlip = false;
      } else {
        // Swipe Right -> Prev Page
        shouldFlip = true;
        // Verify we aren't trying to go before first page
        if (!canNavigate(false)) shouldFlip = false;
      }
    }

    if (shouldFlip) {
      if (dragDistance < 0) {
        appState.isSwipeInProgress = true;
        animationController.triggerFlip(true);
      } else {
        appState.isSwipeInProgress = true;
        animationController.triggerFlip(false);
      }
    }
  }

  /// Navigates to the previous page with error handling
  void navigateToPreviousPage(BuildContext context) {
    if (canNavigate(false)) {
      animationController.triggerFlip(false);
    } else {
      _showNavigationError(context, 'Already at the first page');
    }
  }

  /// Navigates to the next page with error handling
  void navigateToNextPage(BuildContext context) {
    if (canNavigate(true)) {
      animationController.triggerFlip(true);
    } else {
      _showNavigationError(context, 'Already at the last page');
    }
  }

  /// Checks if navigation is possible in the given direction
  bool canNavigate(bool swipeLeft) {
    if (appState.document == null) return false;
    final totalPages = appState.document!.pagesCount;

    if (swipeLeft) {
      /// Next page: allow if we are not at the last page
      return appState.currentPage < totalPages - 1;
    } else {
      /// Previous page: allow if we are not at the first page
      return appState.currentPage > 0;
    }
  }

  /// Shows navigation error message
  void _showNavigationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
