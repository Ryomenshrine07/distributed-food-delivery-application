import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:delivery_app/features/assignment/presentation/providers/assignment_providers.dart';

part 'app_lifecycle_handler.g.dart';

@riverpod
AppLifecycleHandler appLifecycleHandler(Ref ref) {
  final handler = AppLifecycleHandler(ref);
  WidgetsBinding.instance.addObserver(handler);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(handler);
  });
  return handler;
}

class AppLifecycleHandler extends WidgetsBindingObserver {
  final Ref ref;

  AppLifecycleHandler(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App comes to foreground -> Refresh assignments
        // (In a real app you might also refresh active availability or start high-accuracy GPS)
        // Since getActiveAssignment is not directly on notifier, we can just invalidate it if it's a FutureProvider
        // But assignmentController is an AsyncNotifier, so we can't easily call refresh without it being implemented
        // A simple way to refresh is to just call a method on the controller if we add one, or invalidate it.
        ref.invalidate(assignmentControllerProvider);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App goes to background -> could reduce GPS accuracy or pause non-critical streams
        break;
    }
  }
}
