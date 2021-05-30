import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('bloc_enum', () {
    late _FakeEnumBloc bloc;
    late BlocObserver observer;

    setUp(() {
      bloc = _FakeEnumBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('Create', () async {
      expect(() async => await _FakeEnumBloc().close(), returnsNormally);
      expect(bloc is Bloc, isTrue);
      expect(bloc is BlocEnum, isTrue);
      await bloc.close();
    });

    test('Stubbing', () async {
      bloc..add(_FakeEvent.read)..add(_FakeEvent.update);

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <_FakeState>[
            _FakeState.performing,
            _FakeState.fetched,
            _FakeState.performing,
            _FakeState.updated,
          ],
        ),
      );

      expect(bloc.state, equals(_FakeState.updated));

      await bloc.close();
    });

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'expects [] when nothing is added',
      build: () => _FakeEnumBloc(),
      expect: () => <_FakeState>[],
    );

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'Unknown event with assertion error',
      build: () => _FakeEnumBloc(),
      act: (bloc) => bloc.add(_FakeEvent.unknown),
      errors: () => <TypeMatcher>[
        isA<AssertionError>(),
      ],
    );

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'Update -> Update -> Delete',
      build: () => _FakeEnumBloc(),
      act: (bloc) => bloc
        ..add(_FakeEvent.update)
        ..add(_FakeEvent.update)
        ..add(_FakeEvent.delete),
      expect: () => <_FakeState>[
        _FakeState.performing,
        _FakeState.updated,
        _FakeState.performing,
        _FakeState.updated,
        _FakeState.performing,
        _FakeState.deleted,
      ],
    );
  });
}

class _FakeEnumBloc extends Bloc<_FakeEvent, _FakeState>
    with BlocEnum<_FakeEvent, _FakeState> {
  _FakeEnumBloc() : super(_FakeState.initial);

  @override
  Map<_FakeEvent, Function> get router => <_FakeEvent, Function>{
        _FakeEvent.create: _create,
        _FakeEvent.read: _read,
        _FakeEvent.update: _update,
        _FakeEvent.delete: _delete,
      };

  Stream<_FakeState> _create() async* {
    yield _FakeState.performing;
    yield _FakeState.created;
  }

  Stream<_FakeState> _read() async* {
    yield _FakeState.performing;
    yield _FakeState.fetched;
  }

  Stream<_FakeState> _update() async* {
    yield _FakeState.performing;
    yield _FakeState.updated;
  }

  Stream<_FakeState> _delete() async* {
    yield _FakeState.performing;
    yield _FakeState.deleted;
  }
}

enum _FakeEvent {
  create,
  read,
  update,
  delete,
  unknown,
}

enum _FakeState {
  initial,
  performing,
  created,
  fetched,
  updated,
  deleted,
}
