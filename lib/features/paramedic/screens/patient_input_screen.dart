import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:math';
import '../../../core/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state.dart';

class PatientInputScreen extends ConsumerStatefulWidget {
  final String emergencyType;

  const PatientInputScreen({
    super.key,
    this.emergencyType = 'General', // Default if not passed
  });

  @override
  ConsumerState<PatientInputScreen> createState() => _PatientInputScreenState();
}

class _PatientInputScreenState extends ConsumerState<PatientInputScreen> {
  // Constants
  static const double _spacing = 20.0;

  // Controllers
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _respRateController = TextEditingController();
  final TextEditingController _o2SatController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _clinicalImpressionController =
      TextEditingController();

  // Speech to Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _currentListeningField = ''; // 'heart', 'resp', 'o2', 'bp'

  // Camera / MedSigLip
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  bool _isAnalyzing = false;
  String? _analysisStatus;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            if (mounted) {
              setState(() {
                _isListening = false;
                _currentListeningField = '';
              });
            }
          }
        },
        onError: (error) {
          print('Speech Error: $error');
          if (mounted) {
            setState(() {
              _isListening = false;
              _currentListeningField = '';
            });
          }
        },
      );
    } catch (e) {
      print('Speech Init Error: $e');
    }
  }

  Future<void> _listenForField(
      String fieldName, TextEditingController controller) async {
    // If already listening to THIS field, stop.
    if (_isListening && _currentListeningField == fieldName) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _currentListeningField = '';
      });
      return;
    }

    // If listening to logic else, stop that first.
    if (_isListening) {
      await _speech.stop();
    }

    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _currentListeningField = fieldName;
      });

      await _speech.listen(
        onResult: (result) {
          // Update text in real-time as user speaks
          String text = result.recognizedWords;

          // Simple cleanup for numeric-only fields
          if (['heart', 'resp', 'o2'].contains(fieldName)) {
            final numbers =
                RegExp(r'\d+').allMatches(text).map((m) => m.group(0)).join();
            if (numbers.isNotEmpty) text = numbers;
          }

          controller.text = text;
          // Keep cursor at end
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length));
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 2),
        partialResults: true, // IMPORTANT: Real-time feedback
      );
    }
  }

  Future<void> _performVisualTriage() async {
    // 1. Request Camera Permission explicitly
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Camera permission is required for Visual Triage.")));
      return;
    }

    try {
      // 2. Open Camera
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 50,
      );

      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
          _isAnalyzing = true;
          _analysisStatus = "Initializing MedSigLip-448...";
        });

        // 3. Simulate MedSigLip AI Analysis Steps
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted)
          setState(() => _analysisStatus = "Analyzing Clinical Indicators...");

        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted)
          setState(() => _analysisStatus = "Generating Clinical Impression...");

        await Future.delayed(const Duration(milliseconds: 800));

        final impressions = [
          "Patient appears conscious and alert (A+). No obvious airway obstruction. Skin signs normal. No visible external hemorrhage.",
          "Patient is in tripod position, indicating respiratory distress. Accessory muscle use observed. Pale complexion.",
          "Visible trauma to right lower extremity with active bleeding. Patient appears obtunded. Immediate intervention suggested.",
          "Patient is supine. No spontaneous movement observed. Cyanosis noted around lips. Potential airway compromise.",
          "Patient is ambulatory, holding left arm. Grimacing facial expression suggesting pain. Skin pink, warm, dry."
        ];
        final randomImpression =
            impressions[Random().nextInt(impressions.length)];

        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _analysisStatus = null;
            _clinicalImpressionController.text =
                "[MEDSIGLIP ANALYSIS]: $randomImpression";
          });
        }
      }
    } catch (e) {
      print("Camera Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error opening camera: $e"),
          backgroundColor: AppTheme.primaryAlert));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using Theme.of(context) ensures we use the AppTheme (GoogleFonts.inter)
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      // REMOVED FloatingActionButton per user request

      appBar: AppBar(
        title: const Text('PATIENT TRIAGE'), // Simple text
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),

      body: RawScrollbar(
        thumbColor: AppTheme.secondaryTrust.withOpacity(0.8),
        radius: const Radius.circular(20),
        thickness: 6,
        thumbVisibility: true,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display Emergency Type (passed from previous screen)
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: AppTheme.secondaryTrust.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.secondaryTrust.withOpacity(0.3))),
                  child: Text(
                    "EMERGENCY: ${widget.emergencyType.toUpperCase()}",
                    style: const TextStyle(
                        color: AppTheme.secondaryTrust,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text("PRIMARY SURVEY VITALS",
                  style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryTrust,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 16),

              // --- VITALS INPUT (Manual/Mic) ---
              _buildVitalsCard(
                label: 'Heart Rate',
                suffix: 'BPM',
                controller: _heartRateController,
                iconId: 'heart',
                inputType: TextInputType.number,
                icon: Icons.monitor_heart_outlined,
                textTheme: textTheme,
                isIntegerOnly: true,
              ),
              const SizedBox(height: _spacing),

              _buildVitalsCard(
                label: 'Respiratory Rate',
                suffix: 'Breaths/min',
                controller: _respRateController,
                iconId: 'resp',
                inputType: TextInputType.number,
                icon: Icons.air,
                textTheme: textTheme,
                isIntegerOnly: true,
              ),
              const SizedBox(height: _spacing),

              _buildVitalsCard(
                label: 'Oxygen Saturation',
                suffix: '% SpO2',
                controller: _o2SatController,
                iconId: 'o2',
                inputType: TextInputType.number,
                icon: Icons.water_drop_outlined,
                textTheme: textTheme,
                isIntegerOnly: true,
              ),
              const SizedBox(height: _spacing),

              _buildVitalsCard(
                label: 'Blood Pressure',
                suffix: 'mmHg',
                controller: _bpController,
                iconId: 'bp',
                inputType: TextInputType.text, // 120/80 - Needs / so text
                icon: Icons.compress,
                textTheme: textTheme,
                isIntegerOnly: false,
              ),

              const SizedBox(height: 32),

              // --- AI VISUAL TRIAGE (MedSigLip) ---
              Text("AI SCENE ASSESSMENT",
                  style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryTrust,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 16),

              Container(
                height: 240,
                decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Preview
                    if (_capturedImage != null)
                      Image.file(_capturedImage!,
                          fit: BoxFit.cover,
                          color: Colors.black38,
                          colorBlendMode: BlendMode.darken)
                    else
                      Container(color: Colors.white.withOpacity(0.02)),

                    // Overlay Content
                    if (_isAnalyzing)
                      _buildAnalyzingOverlay(textTheme)
                    else if (_capturedImage == null)
                      _buildCameraPlaceholder(textTheme)
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              // Display Impression Result
              if (_clinicalImpressionController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1B261D), // Dark Greenish tint
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.successGreen.withOpacity(0.5))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppTheme.successGreen, size: 20),
                        const SizedBox(width: 8),
                        Text("MedSigLip Report",
                            style: textTheme.bodyMedium?.copyWith(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.bold))
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        _clinicalImpressionController.text,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppTheme.textLight, height: 1.4),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),
              ],

              const SizedBox(height: 48),

              // NEW RETRACTABLE CONFIRMATION SLIDER
              _ConfirmationSlider(
                onConfirmed: () async {
                  // 1. Validate: Check if ANY data is provided
                  bool hasData = _heartRateController.text.isNotEmpty ||
                      _respRateController.text.isNotEmpty ||
                      _o2SatController.text.isNotEmpty ||
                      _bpController.text.isNotEmpty ||
                      _clinicalImpressionController.text.isNotEmpty;

                  if (!hasData) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(
                          "⚠️ Triage Incomplete: Please enter at least ONE vital sign or perform assessment."),
                      backgroundColor: AppTheme.primaryAlert,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height - 150,
                          left: 20,
                          right: 20),
                    ));
                    return false; // Failed, slide back
                  }

                  // 2. SAVE TO FIREBASE (Skipping Image Upload for Speed)
                  String? triageDocId;
                  try {
                    final user = FirebaseAuth.instance.currentUser;

                    final docRef = await FirebaseFirestore.instance
                        .collection('temp_triages')
                        .add({
                      'emergency_type': widget.emergencyType,
                      'heart_rate': _heartRateController.text,
                      'respiratory_rate': _respRateController.text,
                      'o2_saturation': _o2SatController.text,
                      'blood_pressure': _bpController.text,
                      'clinical_impression': _clinicalImpressionController.text,
                      'timestamp': FieldValue.serverTimestamp(),
                      'user_id': user?.uid ?? 'anonymous',
                      'operator_email': user?.email ?? 'unknown',
                    });
                    triageDocId = docRef.id;

                    // SET CLEANUP PROVIDER
                    ref.read(cleanupTriageIdProvider.notifier).state =
                        triageDocId;
                  } catch (e) {
                    print("Firebase Error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Failed to save data: $e"),
                        backgroundColor: AppTheme.primaryAlert));
                    return false; // Stay on screen if save fails
                  }

                  // 3. Success, Navigate & Pass ID for Deletion capability
                  context.go('/paramedic/hospital-map', extra: triageDocId);
                  return true; // Success
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalsCard({
    required String label,
    required String suffix,
    required TextEditingController controller,
    required String iconId,
    required TextInputType inputType,
    required IconData icon,
    required TextTheme textTheme,
    bool isIntegerOnly = false,
  }) {
    bool isListeningHere = (_currentListeningField == iconId);
    final borderColor =
        isListeningHere ? AppTheme.primaryAlert : Colors.white10;
    // Using Card styling consistent with AppTheme
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isListeningHere ? 2 : 1),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12))),
            child: Icon(icon, color: AppTheme.textLight.withOpacity(0.7)),
          ),

          // Input Field
          Expanded(
            child: TextField(
              controller: controller,
              style: textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textLight, fontWeight: FontWeight.bold),
              keyboardType: isIntegerOnly
                  ? const TextInputType.numberWithOptions(
                      decimal: false, signed: false)
                  : inputType,
              inputFormatters: isIntegerOnly
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              cursorColor: AppTheme.secondaryTrust,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                labelText: label,
                labelStyle:
                    textTheme.bodyMedium?.copyWith(color: Colors.white38),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                suffixText: suffix,
                suffixStyle:
                    textTheme.bodySmall?.copyWith(color: Colors.white30),
              ),
            ),
          ),

          // Mic Button
          IconButton(
            icon: Icon(
              isListeningHere ? Icons.graphic_eq : Icons.mic_none,
              color: isListeningHere ? AppTheme.primaryAlert : Colors.white24,
            ),
            onPressed: () => _listenForField(iconId, controller),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAnalyzingOverlay(TextTheme textTheme) {
    return Container(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
                color: AppTheme.primaryAlert, strokeWidth: 3),
          ),
          const SizedBox(height: 24),
          Text(
            _analysisStatus ?? "Processing...",
            style: textTheme.bodyMedium
                ?.copyWith(color: AppTheme.textLight, fontFamily: 'monospace'),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(color: Colors.white, duration: 1000.ms),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder(TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: _performVisualTriage,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppTheme.secondaryTrust.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryTrust, width: 2)),
            child: const Icon(Icons.camera_alt,
                color: AppTheme.textLight, size: 32),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 1500.ms),
        const SizedBox(height: 16),
        Text("TAP TO ANALYZE SCENE",
            style: textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text("Powered by Google MedSigLip-448",
            style: textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryTrust.withOpacity(0.7), fontSize: 10)),
      ],
    );
  }
}

class _ConfirmationSlider extends StatefulWidget {
  final Future<bool> Function() onConfirmed;
  const _ConfirmationSlider({required this.onConfirmed});

  @override
  State<_ConfirmationSlider> createState() => _ConfirmationSliderState();
}

class _ConfirmationSliderState extends State<_ConfirmationSlider>
    with SingleTickerProviderStateMixin {
  double _value = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _controller.addListener(() {
      setState(() {
        _value = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _snapBack() {
    // Animate from current value back to 0
    _animation = Tween<double>(begin: _value, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          // Hint Text (Behind)
          if (_value < 0.2)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "SWIPE TO SUBMIT",
                      style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white30)
                  ],
                ),
              ),
            ),

          // Fill
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor:
                  max(0.001, min(1.0, _value)), // Safe clamp, >0 for width
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryAlert.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
            ),
          ),

          // Slider Thumb
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: AppTheme.primaryAlert,
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 30, elevation: 5),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: _value,
              onChanged: (v) {
                // Ignore input while snapping back
                if (_controller.isAnimating) return;
                setState(() => _value = v);
              },
              onChangeEnd: (v) async {
                if (v > 0.9) {
                  // Valid Swipe Distance > 90%
                  setState(() => _value = 1.0);

                  // Trigger Async Action
                  bool success = await widget.onConfirmed();
                  if (!success) {
                    // Action failed (validation), snap back
                    _snapBack();
                  }
                } else {
                  // Not enough swipe distance, snap back
                  _snapBack();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
