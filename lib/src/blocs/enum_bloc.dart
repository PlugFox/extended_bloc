import 'package:bloc/bloc.dart';

/// BLoC with primitive events.
///
/// Override [router] and create generators.
///
/// Example usage:
/// ```dart
/// class MyEnumBloc extends EnumBloc<Event, State> {
///   MyEnumBloc() : super(State.initial);
///
///   @override
///   Map<Event, Function> get router =>
///     <Event, Function>{
///       Event.read : _read,
///     };
///
///   Stream<MockState> _read() async* {
///     yield State.performing;
///     // ...
///     yield State.fetched;
///   }
/// }
/// ```
///
abstract class EnumBloc<Event, State> extends Bloc<Event, State> {
  /// BLoC with primitive events.
  EnumBloc(State initialState) : super(initialState);

  Map<Event, Function> _routerCache;
  Map<Event, Function> _internalRouter() => _routerCache ??= router;

  /// Sets the generator router by event type
  ///
  /// @override
  /// Map<Event, Function> get router =>
  ///   <Event, Function>{
  ///     CRUD.create      : _createStateGenerator,
  ///     CRUD.readEvent   : _readStateGenerator,
  ///     CRUD.updateEvent : _updateStateGenerator,
  ///     CRUD.deleteEvent : _deleteStateGenerator,
  ///   }
  Map<Event, Function> get router;

  @override
  Stream<State> mapEventToState(Event event) {
    final internalRouter = _internalRouter();
    assert(
      internalRouter.containsKey(event),
      '_eventRouter in RouterBloc must contain $event key',
    );
    if (!internalRouter.containsKey(event)) return Stream<State>.empty();
    return internalRouter[event]() as Stream<State>;
  }
}
