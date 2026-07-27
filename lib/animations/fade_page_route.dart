import 'package:flutter/material.dart';

/// Material page route with a smooth fade transition.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  FadePageRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 450),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(opacity: curved, child: child);
          },
        );
}
