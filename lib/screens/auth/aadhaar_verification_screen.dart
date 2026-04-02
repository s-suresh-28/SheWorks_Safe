import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../core/theme.dart';

class AadhaarVerificationScreen extends StatefulWidget {
  const AadhaarVerificationScreen({Key? key}) : super(key: key);

  @override
  State<AadhaarVerificationScreen> createState() => _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  bool _isScanning = false;
  bool _scanComplete = false;
  String _scanStatus = '';
  
  // Simulated OCR results
  final String _simulatedGender = 'Female';
  final int _simulatedAge = 24;

  void _simulateScan() async {
    setState(() {
      _isScanning = true;
      _scanStatus = 'Scanning Aadhaar details...';
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    
    setState(() {
      _isScanning = false;
      _scanComplete = true;
    });

    if (_simulatedGender == 'Female' && _simulatedAge >= 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification Successful! Proceeding...'), backgroundColor: Colors.green),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignupScreen(age: _simulatedAge, isVerifiedFemale: true),
          ),
        );
      });
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Access Denied'),
          content: const Text('Access restricted to women aged 18+ only.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _scanComplete = false;
                });
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entry Verification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 80, color: AppTheme.primaryPurple),
              const SizedBox(height: 20),
              const Text(
                'Upload Aadhaar for Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                ),
                child: _isScanning 
                    ? const Center(child: CircularProgressIndicator())
                    : _scanComplete
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                                Text('Gender: $_simulatedGender', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Age: $_simulatedAge', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.credit_card, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to Upload Front Side'),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: 30),
              if (_isScanning)
                Text(_scanStatus, style: TextStyle(color: AppTheme.primaryPurple))
              else
                ElevatedButton.icon(
                  onPressed: _scanComplete ? null : _simulateScan,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Simulate Aadhaar Upload'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Privacy: We do NOT store your Aadhaar data. Verification is temporary and local.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
