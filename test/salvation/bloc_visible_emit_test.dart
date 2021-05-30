import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('visible_emit', () {
    late _MockBloc bloc;
    late BlocObserver observer;

    setUp(() {
      bloc = _MockBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('create', () async {
      expect(() async => await _MockBloc().close(), returnsNormally);
      expect(bloc is Bloc, isTrue);
      expect(bloc is BlocVisibleEmit, isTrue);
      await bloc.close();
    });

    test('order', () async {
      bloc
        ..add(_MockEvent.sync)
        ..add(_MockEvent.async)
        ..add(_MockEvent.sync)
        ..add(_MockEvent.sync);

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <_MockState>[
            _MockState.performing,
            _MockState.performed,
            _MockState.performing,
            _MockState.performed,
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
      build: () => _MockBloc(),
      expect: () => <_MockState>[],
    );

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'sync events added',
      build: () => _MockBloc(),
      act: (bloc) => bloc..add(_MockEvent.sync)..add(_MockEvent.sync),
      expect: () => <_MockState>[
        _MockState.performing,
        _MockState.performed,
        _MockState.performing,
        _MockState.performed,
      ],
    );

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'async events added',
      build: () => _MockBloc(),
      act: (bloc) => bloc..add(_MockEvent.async)..add(_MockEvent.async),
      expect: () => <_MockState>[
        _MockState.performing,
        _MockState.performed,
        _MockState.performing,
        _MockState.performed,
      ],
    );
  });
}

class _MockBloc extends Bloc<_MockEvent, _MockState>
    with BlocVisibleEmit<_MockState> {
  _MockBloc() : super(_MockState.initial);

  @override
  Stream<_MockState> mapEventToState(_MockEvent event) {
    if (_MockEvent.sync == event) {
      return _sync();
    } else {
      return _async();
    }
  }

  Stream<_MockState> _sync() async* {
    emit(_MockState.performing);
    emit(_MockState.performed);
  }

  Stream<_MockState> _async() async* {
    emit(_MockState.performing);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    emit(_MockState.performed);
  }
}

enum _MockEvent {
  sync,
  async,
}

enum _MockState {
  initial,
  performing,
  performed,
}
