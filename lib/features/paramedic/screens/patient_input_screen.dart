import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme.dart';

class PatientInputScreen extends StatefulWidget {
  const PatientInputScreen({super.key});

  @override
  State<PatientInputScreen> createState() => _PatientInputScreenState();
}

class _PatientInputScreenState extends State<PatientInputScreen> {
  bool _isListening = false;
  String _liveTranscript = "Tap and hold microphone to speak...";
  
  void _startListening() {
    setState(() {
      _isListening = true;
      _liveTranscript = "Google Gemini Listening...";
    });
    
    // Simulating AI processing delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _liveTranscript = "Male, approx 40s. BP 140/90. Severe chest pain. Conscious but unstable.";
        });
      }
    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Patient Triage'),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            const SizedBox(height: 24),
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'EN ROUTE - INPUT VITALS',
                style: TextStyle(color: AppTheme.primaryAlert, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
            
            const Spacer(),

            // Big Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BigInputButton(
                  icon: Icons.mic,
                  label: 'HOLD TO SPEAK',
                  isActive: _isListening,
                  onDown: _startListening,
                  onUp: _stopListening,
                ),
                const SizedBox(width: 24),
                _BigInputButton(
                  icon: Icons.camera_alt,
                  label: 'SCAN VITALS',
                  isActive: false,
                  onDown: () {},
                  onUp: () {},
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Live Transcript / AI Feedback
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isListening ? AppTheme.secondaryTrust : Colors.transparent),
              ),
              child: Column(
                children: [
                  if (_isListening)
                    const Icon(Icons.graphic_eq, color: AppTheme.secondaryTrust, size: 40)
                        .animate(onPlay: (controller) => controller.repeat())
                        .shakeX(amount: 20, duration: 500.ms),
                  const SizedBox(height: 16),
                  Text(
                    _liveTranscript,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Slider to Confirm (Mocked as button for speed, or simple slider)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _ConfirmationSlider(
                onConfirmed: () {
                   context.go('/paramedic/hospital-map');
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BigInputButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _BigInputButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onDown,
    required this.onUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.secondaryTrust : const Color(0xFF263238),
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [BoxShadow(color: AppTheme.secondaryTrust.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationSlider extends StatefulWidget {
  final VoidCallback onConfirmed;
  const _ConfirmationSlider({required this.onConfirmed});

  @override
  State<_ConfirmationSlider> createState() => _ConfirmationSliderState();
}

class _ConfirmationSliderState extends State<_ConfirmationSlider> {
  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Stack(
        children: [
          const Center(
            child: Text(
              'SWIPE TO SEND ALERT  >>> ',
              style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.2 + (0.8 * _value), // Visual fill
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryAlert.withOpacity(_value),
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: AppTheme.primaryAlert,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 30),
            ),
            child: Slider(
              value: _value,
              onChanged: (v) {
                setState(() => _value = v);
                if (v == 1.0) widget.onConfirmed();
              },
            ),
          ),
        ],
      ),
    );
  }
}
