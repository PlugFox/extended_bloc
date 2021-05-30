import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  group('wo_equality', () {
    late _FakeBloc fakeBloc;
    late BlocObserver observer;

    setUp(() {
      fakeBloc = _FakeBloc();
      observer = BlocObserver();
      Bloc.observer = observer;
    });

    test('create', () async {
      expect(() async => await _FakeBloc().close(), returnsNormally);
      expect(fakeBloc is Bloc, isTrue);
      expect(fakeBloc is BlocWithoutEquality, isTrue);
      await fakeBloc.close();
    });

    test(
      'order',
      () async {
        fakeBloc..add(_FakeEvent())..add(_FakeEvent());

        expect(fakeBloc.state, equals(const _FakeState()));

        await expectLater(
          fakeBloc.stream,
          emitsInOrder(
            <_FakeState>[
              const _FakeState(),
              const _FakeState(),
              const _FakeState(),
              const _FakeState(),
              const _FakeState(),
              const _FakeState(),
              const _FakeState(),
              const _FakeState(),
            ],
          ),
        );

        expect(fakeBloc.state, equals(const _FakeState()));

        await fakeBloc.close();
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'expects [] when nothing is added',
      build: () => _FakeBloc(),
      expect: () => <_FakeState>[],
    );

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      'same events added',
      build: () => _FakeBloc(),
      act: (bloc) => bloc..add(_FakeEvent())..add(_FakeEvent()),
      expect: () => <_FakeState>[
        const _FakeState(),
        const _FakeState(),
        const _FakeState(),
        const _FakeState(),
        const _FakeState(),
        const _FakeState(),
        const _FakeState(),
        const _FakeState(),
      ],
    );

    blocTest<Bloc<_FakeEvent, _FakeState>, _FakeState>(
      '_FakeErrorBloc with broken emit throws Exception when event is added',
      build: () => _FakeErrorBloc(),
      act: (bloc) => bloc.add(_FakeEvent()),
      errors: () => <Object>[
        isA<Exception>(),
      ],
    );
  });
}

class _FakeBloc extends Bloc<_FakeEvent, _FakeState>
    with BlocWithoutEquality<_FakeEvent, _FakeState> {
  _FakeBloc() : super(const _FakeState());

  @override
  Stream<_FakeState> mapEventToState(_FakeEvent event) async* {
    yield const _FakeState();
    yield const _FakeState();
    emit(const _FakeState());
    emit(const _FakeState());
  }
}

class _FakeErrorBloc extends Bloc<_FakeEvent, _FakeState>
    with BlocWithoutEquality<_FakeEvent, _FakeState> {
  _FakeErrorBloc() : super(const _FakeState());

  @override
  Stream<_FakeState> mapEventToState(_FakeEvent event) async* {
    yield const _FakeState();
  }

  @override
  Never emit(_FakeState state) => throw Exception('Some error');

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
  }
}

class _FakeEvent {}

@immutable
class _FakeState {
  @literal
  const _FakeState();

  @override
  bool operator ==(Object other) => true;

  @override
  int get hashCode => 0;
}
