import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:test/test.dart';

final Matcher throwsAssertionError = throwsA(isA<AssertionError>());

void main() {
  group('bloc_router', () {
    late MockRouterBloc bloc;
    late BlocObserver observer;

    setUp(() {
      bloc = MockRouterBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('create', () async {
      expect(() async => await MockRouterBloc().close(), returnsNormally);
      expect(bloc is Bloc, isTrue);
      expect(bloc is BlocRouter, isTrue);
      await bloc.close();
    });

    test('stubbing', () async {
      bloc..add(PerformEvent())..add(PerformEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <MockState>[
            MockState.performing,
            MockState.performed,
            MockState.performing,
            MockState.performed,
          ],
        ),
      );

      expect(bloc.state, equals(MockState.performed));

      await bloc.close();
    });

    blocTest<Bloc<MockEvent, MockState>, MockState>(
      'expects [] when nothing is added',
      build: () => MockRouterBloc(),
      expect: () => <MockState>[],
    );

    blocTest<Bloc<MockEvent, MockState>, MockState>(
      'Unknown event with assertion error',
      build: () => MockRouterBloc(),
      act: (bloc) => bloc.add(UnknownEvent()),
      errors: () => <TypeMatcher>[
        isA<AssertionError>(),
      ],
    );

    blocTest<Bloc<MockEvent, MockState>, MockState>(
      'Perform -> Perform',
      build: () => MockRouterBloc(),
      act: (bloc) => bloc..add(PerformEvent())..add(PerformEvent()),
      expect: () => <MockState>[
        MockState.performing,
        MockState.performed,
        MockState.performing,
        MockState.performed,
      ],
    );
  });
}

mixin MockEvent {}

class PerformEvent with MockEvent {}

class UnknownEvent with MockEvent {}

class MockRouterBloc extends Bloc<MockEvent, MockState>
    with BlocRouter<MockEvent, MockState> {
  MockRouterBloc() : super(MockState.initial);

  @override
  Map<Type, Function> get router => <Type, Function>{
        PerformEvent: _perform,
      };

  Stream<MockState> _perform(PerformEvent event) async* {
    yield MockState.performing;
    yield MockState.performed;
  }
}

enum MockState {
  initial,
  performing,
  performed,
}
