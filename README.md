![](https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png)  
  
  
# Extended [BLoC](https://pub.dev/packages/bloc)
[![Actions Status](https://github.com/PlugFox/extended_bloc/workflows/extended_bloc/badge.svg)](https://github.com/PlugFox/extended_bloc/actions)
[![Coverage](https://codecov.io/gh/PlugFox/extended_bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/PlugFox/extended_bloc)
[![Pub](https://img.shields.io/pub/v/extended_bloc.svg)](https://pub.dev/packages/extended_bloc)
[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-brightgreen.svg)](https://en.wikipedia.org/wiki/WTFPL)
[![effective_dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
  
This package extends the functionality of the package [bloc](https://pub.dev/packages/bloc) by [Felix Angelov](https://github.com/felangel)  
  
  
## EnumBloc<Event, State>  
  
BLoC with primitive events.  
  
Override `router` and create generators.  
 
#### Example usage:  
```dart
class MyEnumBloc extends EnumBloc<Event, State> {

  MyEnumBloc() : super(State.initial);

  @override
  Map<Event, Function> get router =>
    <Event, Function>{
      Event.read : _read,
    };

  Stream<MockState> _read() async* {
    yield State.performing;
    // ...
    yield State.fetched;
  }
}
```
  
## RouterBloc<Event, State>  
  
BLoC with complex events, containing internal data.  
  
Override `router` and create generators.  
  
#### Example usage:  
```dart
class MyRouterBloc extends RouterBloc<Event, State> {

  MyRouterBloc() : super(InitialState());

  @override
  Map<Type, Function> get router =>
    <Type, Function>{
      PerformEvent : _perform,
    };

  Stream<State> _perform(PerformEvent event) async* {
    yield PerformingState();
    // ...
    yield PerformedState();
  }
}
```
  
  
## Coverage  
  
[![](https://codecov.io/gh/PlugFox/extended_bloc/branch/dev/graphs/sunburst.svg)](https://codecov.io/gh/PlugFox/extended_bloc/branch/master)  
  
  
## Changelog  
  
Refer to the [Changelog](https://github.com/plugfox/extended_bloc/blob/master/CHANGELOG.md) to get all release notes.  
  
  
## Features and bugs  
  
Please file feature requests and bugs at the [issue tracker][tracker].
  
[tracker]: https://github.com/PlugFox/extended_bloc/issues
  
  
## Maintainers  
  
[Plague Fox](https://plugfox.dev)  
  
  
## License  
  
[WTFPL](https://github.com/plugfox/extended_bloc/blob/master/LICENSE)  
  
  