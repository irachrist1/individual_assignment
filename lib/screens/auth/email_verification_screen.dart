import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _resendEnabled = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    // Poll every 4 seconds to check if email has been verified
    _timer = Timer.periodic(const Duration(seconds: 4), (_) async {
      await context.read<AuthProvider>().checkEmailVerification();
      if (!mounted) return;
      if (context.read<AuthProvider>().status == AuthStatus.authenticated) {
        _timer?.cancel();
        // Pop everything back to the root so _RootRouter shows HomeScreen.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (!_resendEnabled) return;
    setState(() {
      _resendEnabled = false;
      _resendCooldown = 30;
    });
    await context.read<AuthProvider>().resendVerificationEmail();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email sent!'),
        backgroundColor: Colors.green,
      ),
    );
    // Cooldown countdown
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          _resendEnabled = true;
          t.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined,
                size: 90, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Check Your Email',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 12),
            const Text(
              'We sent a verification link to your email address. '
              'Please click the link to verify your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              'This screen will automatically proceed once verified.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 36),
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Checking verification status...',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 36),
            OutlinedButton.icon(
              onPressed: _resendEnabled ? _resendEmail : null,
              icon: const Icon(Icons.refresh),
              label: Text(_resendEnabled
                  ? 'Resend Verification Email'
                  : 'Resend in $_resendCooldown s'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.pop(context);
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
