import 'package:test/test.dart';

import 'router/bloc_enum_test.dart' as bloc_enum;
import 'router/bloc_router_test.dart' as bloc_router;

void main() {
  group('extended_bloc', () {
    bloc_enum.main();
    bloc_router.main();
  });
}
