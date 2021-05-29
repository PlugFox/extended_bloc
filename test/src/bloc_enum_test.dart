import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:test/test.dart';

final Matcher throwsAssertionError = throwsA(isA<AssertionError>());

void main() {
  group('bloc_enum', () {
    late MockEnumBloc bloc;
    late BlocObserver observer;

    setUp(() {
      bloc = MockEnumBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('Create', () async {
      expect(() async => await MockEnumBloc().close(), returnsNormally);
      expect(bloc is Bloc, isTrue);
      expect(bloc is BlocEnum, isTrue);
      await bloc.close();
    });

    test('Stubbing', () async {
      bloc..add(MockEvent.read)..add(MockEvent.update);

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <MockState>[
            MockState.performing,
            MockState.fetched,
            MockState.performing,
            MockState.updated,
          ],
        ),
      );

      expect(bloc.state, equals(MockState.updated));

      await bloc.close();
    });

    blocTest<Bloc<MockEvent, MockState>, MockState>(
      'expects [] when nothing is added',
      build: () => MockEnumBloc(),
      expect: () => <MockState>[],
    );

    blocTest<Bloc<MockEvent, MockState>, MockState>(
      'Unknown event with assertion error',
      build: () => MockEnumBloc(),
      act: (bloc) => bloc.add(MockEvent.unknown),
      errors: () => <TypeMatcher>[
        isA<AssertionError>(),
      ],
    );

    blocTest<Bloc<MockEvent, MockState>, MockState>(
      'Update -> Update -> Delete',
      build: () => MockEnumBloc(),
      act: (bloc) => bloc
        ..add(MockEvent.update)
        ..add(MockEvent.update)
        ..add(MockEvent.delete),
      expect: () => <MockState>[
        MockState.performing,
        MockState.updated,
        MockState.performing,
        MockState.updated,
        MockState.performing,
        MockState.deleted,
      ],
    );
  });
}

class MockEnumBloc extends Bloc<MockEvent, MockState>
    with BlocEnum<MockEvent, MockState> {
  MockEnumBloc() : super(MockState.initial);

  @override
  Map<MockEvent, Function> get router => <MockEvent, Function>{
        MockEvent.create: _create,
        MockEvent.read: _read,
        MockEvent.update: _update,
        MockEvent.delete: _delete,
      };

  Stream<MockState> _create() async* {
    yield MockState.performing;
    yield MockState.created;
  }

  Stream<MockState> _read() async* {
    yield MockState.performing;
    yield MockState.fetched;
  }

  Stream<MockState> _update() async* {
    yield MockState.performing;
    yield MockState.updated;
  }

  Stream<MockState> _delete() async* {
    yield MockState.performing;
    yield MockState.deleted;
  }
}

enum MockEvent {
  create,
  read,
  update,
  delete,
  unknown,
}

enum MockState {
  initial,
  performing,
  created,
  fetched,
  updated,
  deleted,
}
