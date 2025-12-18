import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock History Data
    final historyItems = [
      {
        'id': '1',
        'type': 'Cardiac',
        'timestamp': 'Today, 10:45 AM',
        'hospital': 'Lilavati Hospital',
        'status': 'Completed',
        'color': Colors.red,
      },
      {
        'id': '2',
        'type': 'Trauma',
        'timestamp': 'Yesterday, 4:20 PM',
        'hospital': 'Breach Candy Hospital',
        'status': 'Completed',
        'color': Colors.orange,
      },
      {
        'id': '3',
        'type': 'Respiratory',
        'timestamp': 'Dec 15, 9:30 AM',
        'hospital': 'KEM Hospital',
        'status': 'Completed',
        'color': Colors.blue,
      },
    ];

    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Intake History'),
          backgroundColor: Colors.black,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: historyItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = historyItems[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.history, color: item['color'] as Color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['type'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white),
                        ),
                        Text(
                          item['hospital'] as String,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          item['timestamp'] as String,
                          style: const TextStyle(
                              color: Colors.white30, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['status'] as String,
                      style: const TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
