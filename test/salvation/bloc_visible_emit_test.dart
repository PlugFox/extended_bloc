import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('visible_emit', () {
    late _FakeBloc bloc;
    late BlocObserver observer;

    setUp(() {
      bloc = _FakeBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('create', () async {
      expect(() async => await _FakeBloc().close(), returnsNormally);
      expect(bloc is Bloc, isTrue);
      expect(bloc is BlocVisibleEmit, isTrue);
      await bloc.close();
    });

    test('order', () async {
      bloc
        ..add(_FakeEvent.sync)
        ..add(_FakeEvent.async)
        ..add(_FakeEvent.sync)
        ..add(_FakeEvent.sync);

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <_FakeState>[
            _FakeState.performing,
            _FakeState.performed,
            _FakeState.performing,
            _FakeState.performed,
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
      build: () => _FakeBloc(),
      expect: () => <_FakeState>[],
    );

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'sync events added',
      build: () => _FakeBloc(),
      act: (bloc) => bloc..add(_FakeEvent.sync)..add(_FakeEvent.sync),
      expect: () => <_FakeState>[
        _FakeState.performing,
        _FakeState.performed,
        _FakeState.performing,
        _FakeState.performed,
      ],
    );

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'async events added',
      build: () => _FakeBloc(),
      act: (bloc) => bloc..add(_FakeEvent.async)..add(_FakeEvent.async),
      expect: () => <_FakeState>[
        _FakeState.performing,
        _FakeState.performed,
        _FakeState.performing,
        _FakeState.performed,
      ],
    );
  });
}

class _FakeBloc extends Bloc<_FakeEvent, _FakeState>
    with BlocVisibleEmit<_FakeState> {
  _FakeBloc() : super(_FakeState.initial);

  @override
  Stream<_FakeState> mapEventToState(_FakeEvent event) {
    if (_FakeEvent.sync == event) {
      return _sync();
    } else {
      return _async();
    }
  }

  Stream<_FakeState> _sync() async* {
    emit(_FakeState.performing);
    emit(_FakeState.performed);
  }

  Stream<_FakeState> _async() async* {
    emit(_FakeState.performing);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    emit(_FakeState.performed);
  }
}

enum _FakeEvent {
  sync,
  async,
}

enum _FakeState {
  initial,
  performing,
  performed,
}
