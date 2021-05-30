import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:extended_bloc/extended_bloc.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  group('wo_equality', () {
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
      expect(bloc is BlocWithoutEquality, isTrue);
      await bloc.close();
    });

    test(
      'order',
      () async {
        bloc..add(_MockEvent())..add(_MockEvent());

        await expectLater(
          bloc.stream,
          emitsInOrder(
            <_MockState>[
              const _MockState(),
              const _MockState(),
              const _MockState(),
              const _MockState(),
              const _MockState(),
              const _MockState(),
              const _MockState(),
              const _MockState(),
            ],
          ),
        );

        expect(bloc.state, equals(const _MockState()));

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'expects [] when nothing is added',
      build: () => _MockBloc(),
      expect: () => <_MockState>[],
    );

    blocTest<Bloc<_MockEvent, _MockState>, _MockState>(
      'same events added',
      build: () => _MockBloc(),
      act: (bloc) => bloc..add(_MockEvent())..add(_MockEvent()),
      expect: () => <_MockState>[
        const _MockState(),
        const _MockState(),
        const _MockState(),
        const _MockState(),
        const _MockState(),
        const _MockState(),
        const _MockState(),
        const _MockState(),
      ],
    );
  });
}

class _MockBloc extends Bloc<_MockEvent, _MockState>
    with BlocWithoutEquality<_MockEvent, _MockState> {
  _MockBloc() : super(const _MockState());

  @override
  Stream<_MockState> mapEventToState(_MockEvent event) async* {
    yield const _MockState();
    yield const _MockState();
    emit(const _MockState());
    emit(const _MockState());
  }
}

class _MockEvent {}

@immutable
class _MockState {
  @literal
  const _MockState();

  @override
  bool operator ==(Object other) => true;

  @override
  int get hashCode => 0;
}
