import 'package:flutter/material.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('connection') || errorString.contains('network')) {
      return 'No internet connection. Please check your network.';
    } else if (errorString.contains('404')) {
      return 'Resource not found.';
    } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Unauthorized. Please login again.';
    } else if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Access forbidden.';
    } else if (errorString.contains('500') || errorString.contains('server')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

