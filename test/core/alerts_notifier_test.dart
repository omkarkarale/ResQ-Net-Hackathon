import 'package:flutter_test/flutter_test.dart';
import 'package:resq_net/core/state.dart';
import 'package:resq_net/models/data_models.dart';

void main() {
  test('AlertsNotifier correctly prepends new AmbulanceAlert items to state', () {
    final notifier = AlertsNotifier();

    final alert1 = AmbulanceAlert(
      id: 'a1',
      ambulanceId: 'amb-1',
      emergencyType: 'Cardiac',
      notes: 'note-1',
      eta: '5 mins',
      isCritical: false,
      timestamp: DateTime(2025, 1, 1),
    );

    notifier.addAlert(alert1);
    expect(notifier.state, equals([alert1]));

    final alert2 = AmbulanceAlert(
      id: 'a2',
      ambulanceId: 'amb-2',
      emergencyType: 'Trauma',
      notes: 'note-2',
      eta: '10 mins',
      isCritical: true,
      timestamp: DateTime(2025, 1, 2),
    );

    notifier.addAlert(alert2);
    expect(notifier.state, equals([alert2, alert1]));
  });
}
