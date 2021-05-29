import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// BLoC with complex events, containing internal data.
///
/// Override [router] and create generators.
///
/// Example usage:
/// ```dart
/// class MyRouterBloc extends Bloc<MyEvent, MyState>
///    with BlocRouter<MyEvent, MyState> {
///   MyRouterBloc() : super(MyInitialState());
///
///   @override
///   Map<Type, Function> get router =>
///     <Type, Function>{
///       PerformEvent : _perform,
///     };
///
///   Stream<MyState> _perform(PerformEvent event) async* {
///     yield MyPerformingState();
///     // ...
///     yield MyPerformedState();
///   }
/// }
/// ```
///
mixin BlocRouter<Event, State> on Bloc<Event, State> {
  Map<Type, Function>? _routerCache;
  Map<Type, Function> _internalRouter() => _routerCache ??= router;

  /// Sets the generator router by event type
  ///
  /// @override
  /// Map<Type, Function> get router =>
  ///   <Type, Function>{
  ///     CreateEvent : _createStateGenerator,
  ///     ReadEvent   : _readStateGenerator,
  ///     UpdateEvent : _updateStateGenerator,
  ///     DeleteEvent : _deleteStateGenerator,
  ///   }
  @visibleForOverriding
  Map<Type, Function> get router;

  @override
  @internal
  @protected
  @nonVirtual
  @visibleForTesting
  Stream<State> mapEventToState(Event event) {
    final type = event.runtimeType;
    final internalRouter = _internalRouter();
    assert(
      internalRouter.containsKey(type),
      'router in "$runtimeType" BLoC must '
      'contain "$event" with "$type" Type key',
    );
    if (!internalRouter.containsKey(type)) return Stream<State>.empty();
    return internalRouter[type]!(event) as Stream<State>;
  }
}
