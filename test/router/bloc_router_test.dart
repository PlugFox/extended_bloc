import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('bloc_router', () {
    late _FakeRouterBloc bloc;
    late BlocObserver observer;

    setUp(() {
      bloc = _FakeRouterBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('create', () async {
      expect(() async => await _FakeRouterBloc().close(), returnsNormally);
      expect(bloc is Bloc, isTrue);
      expect(bloc is BlocRouter, isTrue);
      await bloc.close();
    });

    test('stubbing', () async {
      bloc..add(_PerformEvent())..add(_PerformEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <_FakeState>[
            _FakeState.performing,
            _FakeState.performed,
            _FakeState.performing,
            _FakeState.performed,
          ],
        ),
      );

      expect(bloc.state, equals(_FakeState.performed));

      await bloc.close();
    });

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'expects [] when nothing is added',
      build: () => _FakeRouterBloc(),
      expect: () => <_FakeState>[],
    );

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'Unknown event with assertion error',
      build: () => _FakeRouterBloc(),
      act: (bloc) => bloc.add(_UnknownEvent()),
      errors: () => <TypeMatcher>[
        isA<AssertionError>(),
      ],
    );

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'Perform -> Perform',
      build: () => _FakeRouterBloc(),
      act: (bloc) => bloc..add(_PerformEvent())..add(_PerformEvent()),
      expect: () => <_FakeState>[
        _FakeState.performing,
        _FakeState.performed,
        _FakeState.performing,
        _FakeState.performed,
      ],
    );
  });
}

mixin _FakeEvent {}

class _PerformEvent with _FakeEvent {}

class _UnknownEvent with _FakeEvent {}

class _FakeRouterBloc extends Bloc<_FakeEvent, _FakeState>
    with BlocRouter<_FakeEvent, _FakeState> {
  _FakeRouterBloc() : super(_FakeState.initial);

  @override
  Map<Type, Function> get router => <Type, Function>{
        _PerformEvent: _perform,
      };

  Stream<_FakeState> _perform(_PerformEvent event) async* {
    yield _FakeState.performing;
    yield _FakeState.performed;
  }
}

enum _FakeState {
  initial,
  performing,
  performed,
}
