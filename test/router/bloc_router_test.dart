import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('bloc_router', () {
    late _MockRouterBloc bloc;
    late BlocObserver observer;

    setUp(() {
      bloc = _MockRouterBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('create', () async {
      expect(() async => await _MockRouterBloc().close(), returnsNormally);
      expect(bloc is Bloc, isTrue);
      expect(bloc is BlocRouter, isTrue);
      await bloc.close();
    });

    test('stubbing', () async {
      bloc..add(_PerformEvent())..add(_PerformEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <_MockState>[
            _MockState.performing,
            _MockState.performed,
            _MockState.performing,
            _MockState.performed,
          ],
        ),
      );

      expect(bloc.state, equals(_MockState.performed));

      await bloc.close();
    });

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'expects [] when nothing is added',
      build: () => _MockRouterBloc(),
      expect: () => <_MockState>[],
    );

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'Unknown event with assertion error',
      build: () => _MockRouterBloc(),
      act: (bloc) => bloc.add(_UnknownEvent()),
      errors: () => <TypeMatcher>[
        isA<AssertionError>(),
      ],
    );

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'Perform -> Perform',
      build: () => _MockRouterBloc(),
      act: (bloc) => bloc..add(_PerformEvent())..add(_PerformEvent()),
      expect: () => <_MockState>[
        _MockState.performing,
        _MockState.performed,
        _MockState.performing,
        _MockState.performed,
      ],
    );
  });
}

mixin _MockEvent {}

class _PerformEvent with _MockEvent {}

class _UnknownEvent with _MockEvent {}

class _MockRouterBloc extends Bloc<_MockEvent, _MockState>
    with BlocRouter<_MockEvent, _MockState> {
  _MockRouterBloc() : super(_MockState.initial);

  @override
  Map<Type, Function> get router => <Type, Function>{
        _PerformEvent: _perform,
      };

  Stream<_MockState> _perform(_PerformEvent event) async* {
    yield _MockState.performing;
    yield _MockState.performed;
  }
}

enum _MockState {
  initial,
  performing,
  performed,
}
