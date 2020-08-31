import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';
import 'package:extended_bloc/router_bloc.dart';

final Matcher throwsAssertionError = throwsA(isA<AssertionError>());

void main() {
  group('router_bloc', () {
    MockRouterBloc bloc;
    BlocObserver observer;

    setUp(() {
      bloc = MockRouterBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('Create', () async {
      expect(() async => await MockRouterBloc().close(), returnsNormally);
      expect(bloc is Bloc, isTrue);
      expect(bloc is RouterBloc, isTrue);
      await bloc.close();
    });

    test('Stubbing', () async {
      bloc..add(PerformEvent())..add(PerformEvent());

      await expectLater(
        bloc,
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

    blocTest<RouterBloc<MockEvent, MockState>, MockState>(
      'expects [] when nothing is added',
      build: () => MockRouterBloc(),
      expect: <MockState>[],
    );

    blocTest<RouterBloc<MockEvent, MockState>, MockState>(
      'Unknown event with assertion error',
      build: () => MockRouterBloc(),
      act: (bloc) => bloc.add(UnknownEvent()),
      errors: <TypeMatcher>[
        isA<AssertionError>(),
      ],
    );

    blocTest<RouterBloc<MockEvent, MockState>, MockState>(
      'Perform -> Perform',
      build: () => MockRouterBloc(),
      act: (bloc) => bloc..add(PerformEvent())..add(PerformEvent()),
      expect: <MockState>[
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

class MockRouterBloc extends RouterBloc<MockEvent, MockState> {
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
