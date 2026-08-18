import 'package:flutter_test/flutter_test.dart';

import 'package:nagdar_app/main.dart';

void main() {
  test('netWage nets rejects across rate lines', () {
    final w = netWage([Line('stitch', 120, 5, 3), Line('button', 200, 0, 0.5)]);
    expect(w, closeTo(445, 1e-9));
  });

  testWidgets('renders the wage slip', (tester) async {
    await tester.pumpWidget(const NagdarApp());
    expect(find.text('Rate lines'), findsOneWidget);
  });
}
