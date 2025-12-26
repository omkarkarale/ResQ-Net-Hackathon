import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';

class SituationDetailsScreen extends ConsumerStatefulWidget {
  const SituationDetailsScreen({super.key});

  @override
  ConsumerState<SituationDetailsScreen> createState() => _SituationDetailsScreenState();
}

class _SituationDetailsScreenState extends ConsumerState<SituationDetailsScreen> {
  int _patientCount = 1;
  String _timeSinceIncident = '< 30 mins';
  String _mechanism = 'Motor Vehicle Accident';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _times = ['< 30 mins', '30-60 mins', '1-2 hours', '2-4 hours', '> 4 hours'];
  final List<String> _mechanisms = [
    'Motor Vehicle Accident',
    'Fall from Height',
    'Assault/Violence',
    'Fire/Explosion',
    'Drowning',
    'Industrial Accident',
    'Sports Injury',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Situation Details'),
          backgroundColor: Colors.black,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionLabel('NUMBER OF PATIENTS'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [1, 2, 3, 4, 5].map((count) {
                final isSelected = _patientCount == count;
                return GestureDetector(
                  onTap: () => setState(() => _patientCount = count),
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.secondaryTrust : Colors.white10,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                    child: Text(
                      count == 5 ? '5+' : '$count',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            _buildSectionLabel('TIME SINCE INCIDENT'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _times.map((time) {
                final isSelected = _timeSinceIncident == time;
                return InputChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _timeSinceIncident = time),
                  backgroundColor: Colors.white10,
                  selectedColor: AppTheme.secondaryTrust,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            _buildSectionLabel('MECHANISM OF INJURY'),
            DropdownButtonFormField<String>(
              initialValue: _mechanism,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _mechanisms.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() {
                if(val != null) _mechanism = val;
              }),
            ),

            const SizedBox(height: 32),
            _buildSectionLabel('SITUATION DESCRIPTION (Required)'),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Describe what happened...',
                hintStyle: TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionLabel('ADDITIONAL DETAILS (Optional)'),
            TextField(
              controller: _notesController,
              maxLines: 2,
              maxLength: 300,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Allergies, hazards, etc.',
                hintStyle: TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                if (_descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a situation description.')),
                  );
                  return;
                }
                context.go('/paramedic/patient-input');
              },
              child: const Text('CONTINUE TO TRIAGE'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
