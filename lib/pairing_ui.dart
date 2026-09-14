import 'package:flutter/material.dart';
import 'caregiver_dash.dart';
import 'murobbi_home.dart';

// 1. CAREGIVER LOGIN & CODE GENERATION
class CaregiverLoginScreen extends StatefulWidget {
  const CaregiverLoginScreen({super.key});

  @override
  State<CaregiverLoginScreen> createState() => _CaregiverLoginScreenState();
}

class _CaregiverLoginScreenState extends State<CaregiverLoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Setup')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailCtrl, 
              decoration: const InputDecoration(
                labelText: 'Email', 
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl, 
              decoration: const InputDecoration(
                labelText: 'Password', 
                border: OutlineInputBorder(),
              ), 
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // BYPASS LOGIN FOR PROTOTYPE
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CaregiverDash()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Login (Bypass)', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. MUROBBI CODE ENTRY
class PrimaryPairingScreen extends StatefulWidget {
  const PrimaryPairingScreen({super.key});

  @override
  State<PrimaryPairingScreen> createState() => _PrimaryPairingScreenState();
}

class _PrimaryPairingScreenState extends State<PrimaryPairingScreen> {
  final TextEditingController _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Caregiver')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the 6-digit code from your Caregiver:', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(), 
                hintText: '123456',
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32, 
                letterSpacing: 10, 
                fontWeight: FontWeight.bold,
              ),
              maxLength: 6,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // BYPASS PAIRING FOR PROTOTYPE
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MurobbiHome()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Connect (Bypass)', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
