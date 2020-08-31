import 'package:bloc/bloc.dart';

/// BLoC with complex events, containing internal data.
///
/// Override [router] and create generators.
///
/// Example usage:
/// ```dart
/// class MyRouterBloc extends RouterBloc<Event, State> {
///   MyRouterBloc() : super(InitialState());
///
///   @override
///   Map<Type, Function> get router =>
///     <Type, Function>{
///       PerformEvent : _perform,
///     };
///
///   Stream<State> _perform(PerformEvent event) async* {
///     yield PerformingState();
///     // ...
///     yield PerformedState();
///   }
/// }
/// ```
///
abstract class RouterBloc<Event, State> extends Bloc<Event, State> {
  /// BLoC with complex events, containing internal data.
  RouterBloc(State initialState) : super(initialState);

  Map<Type, Function> _routerCache;
  Map<Type, Function> _internalRouter() => _routerCache ??= router;

  /// Sets the generator router by event type
  ///
  /// @override
  /// Map<Type, Function> get router =>
  ///   <Type, Function>{
  ///     CreateEvent : _createStateGenerator,
  ///     ReadEvent : _readStateGenerator,
  ///     UpdateEvent : _updateStateGenerator,
  ///     DeleteEvent : _deleteStateGenerator,
  ///   }
  Map<Type, Function> get router;

  @override
  Stream<State> mapEventToState(Event event) async* {
    final type = event.runtimeType;
    final internalRouter = _internalRouter();
    assert(
      internalRouter.containsKey(type),
      'router in RouterBloc must contain $type key',
    );
    if (!internalRouter.containsKey(type)) return;
    yield* internalRouter[type](event) as Stream<State>;
  }
}
