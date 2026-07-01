import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/core/routing/app_router.dart';
import 'package:delivery_app/core/routing/routes.dart';
import 'package:delivery_app/features/authentication/domain/entities/partner_session.dart';
import 'package:delivery_app/features/authentication/domain/repositories/session_repository.dart';

class MockSessionRepository extends Mock implements SessionRepository {}
class MockBuildContext extends Mock implements BuildContext {}
class FakeGoRouterState extends Fake implements GoRouterState {
  final Uri _uri;
  FakeGoRouterState(this._uri);
  
  @override
  Uri get uri => _uri;
}

void main() {
  group('AppRouter Redirect Logic (Property P-4b)', () {
    late MockSessionRepository mockRepo;
    late StreamController<PartnerSession?> streamController;

    setUp(() {
      mockRepo = MockSessionRepository();
      streamController = StreamController<PartnerSession?>.broadcast();
      when(() => mockRepo.sessionChanges).thenAnswer((_) => streamController.stream);
    });

    tearDown(() {
      streamController.close();
    });

    test('Property: routes to /home iff token present AND not expired, else /login', () {
      // Feature: delivery-app, Property P-4b
      
      final mockContext = MockBuildContext();
      final splashState = FakeGoRouterState(Uri.parse(AppRoutes.splash));
      
      final cases = [
        {'isPresent': true, 'isExpired': false},
        {'isPresent': true, 'isExpired': true},
        {'isPresent': false, 'isExpired': false},
      ];
      
      for (final testCase in cases) {
        final isPresent = testCase['isPresent'] as bool;
        final isExpired = testCase['isExpired'] as bool;
        
        PartnerSession? session;
        if (isPresent) {
          final exp = isExpired 
              ? DateTime.now().subtract(const Duration(days: 1)) 
              : DateTime.now().add(const Duration(days: 1));
          session = PartnerSession(
            partnerId: '123',
            email: 'test@example.com',
            role: 'DELIVERY_PARTNER',
            name: 'Test',
            phone: '1234567890',
            exp: exp,
          );
        }
        
        when(() => mockRepo.currentSession).thenReturn(session);
        
        final redirect = appRedirect(mockContext, splashState, mockRepo);
        
        if (isPresent && !isExpired) {
          expect(redirect, AppRoutes.home);
        } else {
          expect(redirect, AppRoutes.login);
        }
      }
    });
  });
}
