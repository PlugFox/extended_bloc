import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// BLoC without States comparison checks
mixin BlocWithoutEquality<E, S> on Bloc<E, S> {
  @override
  @mustCallSuper
  Stream<Transition<E, S>> transformTransitions(
          Stream<Transition<E, S>> transitions) =>
      _StreamWithCustomHandler(
        super.transformTransitions(transitions),
        (transition) {
          try {
            onTransition(transition);
            super.emit(transition.nextState);
            // ignore: avoid_catches_without_on_clauses
          } catch (error, stackTrace) {
            onError(error, stackTrace);
          }
        },
      );
}

class _StreamWithCustomHandler<E, S> extends Stream<Transition<E, S>> {
  final Stream<Transition<E, S>> _source;
  final void Function(Transition<E, S>)? _onDataHandler;
  _StreamWithCustomHandler(
    this._source,
    this._onDataHandler,
  );

  @override
  StreamSubscription<Transition<E, S>> listen(
    void Function(Transition<E, S> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _source.listen(
        _onDataHandler,
        onError: onError,
      );
}
