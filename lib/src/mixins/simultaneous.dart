import 'package:bloc/bloc.dart' show Bloc, Transition, TransitionFunction;
import '../transformers/simultaneous_transformer.dart';

mixin Simultaneous<Event, State> on Bloc<Event, State> {

  @override
  Stream<Transition<Event, State>> transformEvents(
      Stream<Event> events,
      TransitionFunction<Event, State> transitionFn,
      ) => events.simultaneous<Transition<Event, State>>(transitionFn);

}


