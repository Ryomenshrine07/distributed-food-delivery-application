import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:delivery_app/core/error/result.dart';
import 'package:delivery_app/features/availability/domain/repositories/availability_repository.dart';
import 'package:delivery_app/features/availability/presentation/providers/availability_providers.dart';
import 'package:delivery_app/features/availability/presentation/widgets/availability_toggle.dart';

import 'package:delivery_app/features/location/domain/repositories/background_location_repository.dart';
import 'package:delivery_app/features/location/presentation/providers/location_providers.dart';

class MockAvailabilityRepository extends Mock implements AvailabilityRepository {}
class MockBackgroundLocationRepository extends Mock implements BackgroundLocationRepository {}

void main() {
  group('AvailabilityToggle Widget', () {
    late MockAvailabilityRepository mockRepository;
    late MockBackgroundLocationRepository mockBackgroundRepository;

    setUp(() {
      mockRepository = MockAvailabilityRepository();
      mockBackgroundRepository = MockBackgroundLocationRepository();
      when(() => mockBackgroundRepository.init()).thenReturn(null);
      when(() => mockBackgroundRepository.startService()).thenAnswer((_) async {});
      when(() => mockBackgroundRepository.stopService()).thenAnswer((_) async {});
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(mockRepository),
          backgroundLocationRepositoryProvider.overrideWithValue(mockBackgroundRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AvailabilityToggle(),
          ),
        ),
      );
    }

    testWidgets('displays Offline initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('You are Offline'), findsOneWidget);
      expect(find.text('You are Online'), findsNothing);
      expect(find.byType(Switch), findsOneWidget);
      
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('toggles to Online on switch tap', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      clearInteractions(mockRepository);
      clearInteractions(mockBackgroundRepository);
      when(() => mockRepository.goOnline()).thenAnswer((_) async => const Right(null));

      // Tap to go online
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle(); // Finish loading

      verify(() => mockRepository.goOnline()).called(1);
      verify(() => mockBackgroundRepository.init()).called(1);
      verify(() => mockBackgroundRepository.startService()).called(1);

      expect(find.text('You are Online'), findsOneWidget);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('toggles to Offline on switch tap', (tester) async {
      when(() => mockRepository.goOnline()).thenAnswer((_) async => const Right(null));
      when(() => mockRepository.goOffline()).thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('You are Online'), findsOneWidget);
      clearInteractions(mockRepository);
      clearInteractions(mockBackgroundRepository);

      // Now tap to go offline
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      verify(() => mockRepository.goOffline()).called(1);
      verify(() => mockBackgroundRepository.stopService()).called(1);

      expect(find.text('You are Offline'), findsOneWidget);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });
  });
}
