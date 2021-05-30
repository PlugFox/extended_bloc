import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// BLoC without States comparison checks
mixin BlocWithoutEquality<Event extends Object, State extends Object>
    on Bloc<Event, State> {
  StreamController<State>? __stateController;
  StreamController<State> get _stateController =>
      __stateController ??= StreamController<State>.broadcast();

  late State _state;

  @override
  State get state => _state;

  @override
  Stream<State> get stream => _stateController.stream;

  @override
  @nonVirtual
  Stream<Transition<Event, State>> transformTransitions(
      Stream<Transition<Event, State>> transitions) {
    // init _state with sub
    _state = super.state;
    return _StreamBindEventsToStatesInterceptor(
      super.transformTransitions(transitions),
      (transition) {
        try {
          onTransition(transition);
          emit(transition.nextState);
        } on Object catch (error, stackTrace) {
          onError(error, stackTrace);
        }
      },
    );
  }

  @override
  @mustCallSuper
  Future<void> close() async {
    await __stateController?.close();
    return super.close();
  }

  @override
  void emit(State state) {
    if (_stateController.isClosed) return;
    onChange(Change<State>(currentState: this.state, nextState: state));
    _state = state;
    _stateController.add(_state);
  }
}

class _StreamBindEventsToStatesInterceptor<E extends Object, S extends Object>
    extends Stream<Transition<E, S>> {
  final Stream<Transition<E, S>> transitions;
  final void Function(Transition<E, S> event) handler;

  _StreamBindEventsToStatesInterceptor(
    this.transitions,
    this.handler,
  );

  @override
  StreamSubscription<Transition<E, S>> listen(
    void Function(Transition<E, S> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      transitions.listen(
        handler,
        onError: onError,
      );
}
