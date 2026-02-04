import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import 'profile_screen.dart';
import '../widgets/language_selector.dart';

enum OTPVerifyType { signup, recovery }

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final OTPVerifyType type;
  final String? newPassword; // Required for recovery if we want to update it immediately

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.type,
    this.newPassword,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onStepChanged(String value, int index) {
    if (value.length > 1) {
      // Handle pasting
      String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      // If user typed a second char in the same box, numericValue might be length 2
      // We want to handle both pasting (long) and fast typing (2 chars)
      if (numericValue.length > 1 && numericValue.length <= 6) {
        for (int i = 0; i < numericValue.length && (index + i) < 6; i++) {
          _controllers[index + i].text = numericValue[i];
        }
        int nextIndex = index + numericValue.length;
        if (nextIndex > 5) nextIndex = 5;
        _focusNodes[nextIndex].requestFocus();
      } else {
        // Just take the latest character and move on
        String lastChar = numericValue.characters.last;
        _controllers[index].text = lastChar;
        if (index < 5) _focusNodes[index + 1].requestFocus();
      }
    } else if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    
    // Auto-submit if all filled
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _handleVerify();
    }
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() => _isLoading = true);
    try {
      final type = widget.type == OTPVerifyType.signup ? OtpType.signup : OtpType.recovery;
      
      final response = await _authService.verifyOTP(
        email: widget.email,
        token: otp,
        type: type,
      );

      if (mounted) {
        if (widget.type == OTPVerifyType.recovery && widget.newPassword != null) {
          // Update the password now that we're verified and signed in
          await _authService.updatePassword(widget.newPassword!);
          AppTheme.showToast(context, 'Password updated successfully');
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (widget.type == OTPVerifyType.signup) {
          AppTheme.showToast(context, 'Account verified successfully');
          // Navigate to profile creation
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(isNewBusiness: true, isMandatory: true),
            ),
            (route) => false,
          );
        } else {
          // Just recovery without immediate password change (if handled elsewhere)
          Navigator.pop(context, true);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        AppTheme.showToast(context, e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showToast(context, 'Verification failed. Please try again.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.mark_email_read_outlined, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 32),
              Text(
                'Enter Verification Code',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We have sent a 6-digit code to\n${widget.email}',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // OTP Input Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: RawKeyboardListener(
                      focusNode: FocusNode(canRequestFocus: false), // Prevents this dummy node from stealing focus
                      onKey: (event) {
                        if (event is RawKeyDownEvent && 
                            event.logicalKey == LogicalKeyboardKey.backspace) {
                          _handleBackspace(index);
                        }
                      },
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        obscuringCharacter: '*',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                          ),
                        ),
                        onChanged: (value) => _onStepChanged(value, index),
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 48),
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: 'Verify',
                    onPressed: _handleVerify,
                  ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _isLoading ? null : () async {
                  // Resend logic
                  try {
                    if (widget.type == OTPVerifyType.signup) {
                      // Note: Standard signUp doesn't have a "resend" easily without calling signUp again
                      // But resetPassword(for recovery) does.
                      AppTheme.showToast(context, 'Please wait a moment before requesting a new code');
                    } else {
                      await _authService.resetPassword(widget.email);
                      AppTheme.showToast(context, 'Code resent successfully');
                    }
                  } catch (e) {
                    AppTheme.showToast(context, 'Failed to resend code');
                  }
                },
                child: const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
