import 'package:test/test.dart';
import 'src/enum_bloc_test.dart' as enum_bloc;
import 'src/router_bloc_test.dart' as router_bloc;

void main() {
  group('extended_bloc', () {
    enum_bloc.main();
    router_bloc.main();
  });
}
