import 'package:test/test.dart';

import 'src/bloc_enum_test.dart' as bloc_enum;
import 'src/bloc_router_test.dart' as bloc_router;

void main() {
  group('extended_bloc', () {
    bloc_enum.main();
    bloc_router.main();
  });
}
