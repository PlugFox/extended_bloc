import 'package:bloc/bloc.dart';

/// BLoC with visible [emit] method
mixin BlocVisibleEmit<State extends Object> on BlocBase<State> {
  /// {@template emit}
  /// Updates the state of the bloc to the provided [state].
  /// A bloc's state should only be updated by `yielding` a new `state`
  /// from `mapEventToState` in response to an event.
  /// {@endtemplate}
  @override
  void emit(State state) => super.emit(state);
}
