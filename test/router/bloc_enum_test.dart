import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:test/test.dart';

final Matcher throwsAssertionError = throwsA(isA<AssertionError>());

void main() {
  group('bloc_enum', () {
    late _MockEnumBloc bloc;
    late BlocObserver observer;

    setUp(() {
      bloc = _MockEnumBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('Create', () async {
      expect(() async => await _MockEnumBloc().close(), returnsNormally);
      expect(bloc is Bloc, isTrue);
      expect(bloc is BlocEnum, isTrue);
      await bloc.close();
    });

    test('Stubbing', () async {
      bloc..add(_MockEvent.read)..add(_MockEvent.update);

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <_MockState>[
            _MockState.performing,
            _MockState.fetched,
            _MockState.performing,
            _MockState.updated,
          ],
        ),
      );

      expect(bloc.state, equals(_MockState.updated));

      await bloc.close();
    });

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'expects [] when nothing is added',
      build: () => _MockEnumBloc(),
      expect: () => <_MockState>[],
    );

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'Unknown event with assertion error',
      build: () => _MockEnumBloc(),
      act: (bloc) => bloc.add(_MockEvent.unknown),
      errors: () => <TypeMatcher>[
        isA<AssertionError>(),
      ],
    );

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'Update -> Update -> Delete',
      build: () => _MockEnumBloc(),
      act: (bloc) => bloc
        ..add(_MockEvent.update)
        ..add(_MockEvent.update)
        ..add(_MockEvent.delete),
      expect: () => <_MockState>[
        _MockState.performing,
        _MockState.updated,
        _MockState.performing,
        _MockState.updated,
        _MockState.performing,
        _MockState.deleted,
      ],
    );
  });
}

class _MockEnumBloc extends Bloc<_MockEvent, _MockState>
    with BlocEnum<_MockEvent, _MockState> {
  _MockEnumBloc() : super(_MockState.initial);

  @override
  Map<_MockEvent, Function> get router => <_MockEvent, Function>{
        _MockEvent.create: _create,
        _MockEvent.read: _read,
        _MockEvent.update: _update,
        _MockEvent.delete: _delete,
      };

  Stream<_MockState> _create() async* {
    yield _MockState.performing;
    yield _MockState.created;
  }

  Stream<_MockState> _read() async* {
    yield _MockState.performing;
    yield _MockState.fetched;
  }

  Stream<_MockState> _update() async* {
    yield _MockState.performing;
    yield _MockState.updated;
  }

  Stream<_MockState> _delete() async* {
    yield _MockState.performing;
    yield _MockState.deleted;
  }
}

enum _MockEvent {
  create,
  read,
  update,
  delete,
  unknown,
}

enum _MockState {
  initial,
  performing,
  created,
  fetched,
  updated,
  deleted,
}
