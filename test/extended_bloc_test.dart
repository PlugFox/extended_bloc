import 'package:test/test.dart';

import 'router/bloc_enum_test.dart' as bloc_enum;
import 'router/bloc_router_test.dart' as bloc_router;
import 'salvation/bloc_visible_emit_test.dart' as visible_emit;
import 'salvation/bloc_wo_equality_test.dart' as wo_equality;

void main() {
  group('extended_bloc', () {
    bloc_enum.main();
    bloc_router.main();
    visible_emit.main();
    wo_equality.main();
  });
}
