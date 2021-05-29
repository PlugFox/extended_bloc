import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// BLoC with primitive literal events such as enums.
///
/// Override [router] and create generators.
///
/// Example usage:
/// ```dart
/// class MyEnumBloc extends Bloc<MyEvent, MyState>
///    with BlocEnum<MyEvent, MyState> {
///   MyEnumBloc() : super(MyState.initial);
///
///   @override
///   Map<MyEvent, Function> get router =>
///     <MyEvent, Function>{
///       MyEvent.read : _read,
///     };
///
///   Stream<MyState> _read() async* {
///     yield MyState.performing;
///     // ...
///     yield MyState.fetched;
///   }
/// }
/// ```
///
mixin BlocEnum<Event, State> on Bloc<Event, State> {
  Map<Event, Function>? _routerCache;
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
  @visibleForOverriding
  Map<Event, Function> get router;

  @override
  @internal
  @protected
  @nonVirtual
  @visibleForTesting
  Stream<State> mapEventToState(Event event) {
    final internalRouter = _internalRouter();
    assert(
      internalRouter.containsKey(event),
      'router in "$runtimeType" BLoC must contain "$event" key',
    );
    if (!internalRouter.containsKey(event)) return Stream<State>.empty();
    return internalRouter[event]!() as Stream<State>;
  }
}
