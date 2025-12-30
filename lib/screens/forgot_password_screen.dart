import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/supabase_service.dart';
import '../widgets/responsive_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showToast('Please enter your email address', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(email);
      if (mounted) {
        _showToast('Password reset link sent! Check your email.');
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showToast(e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showToast('An unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    AppTheme.showToast(context, message, isError: isError);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildResetForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _animate(
            delay: 100,
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppTheme.premiumShadows,
              ),
              child: const Icon(Icons.lock_reset_outlined, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 24),
          _animate(
            delay: 200,
            child: const Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _animate(
            delay: 300,
            child: Text(
              'Enter your email to receive recovery instructions',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black.withAlpha(140),
              ),
            ),
          ),
          const SizedBox(height: 32),

          _animate(
            delay: 400,
            child: CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'name@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 32),
          _animate(
            delay: 600,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : CustomButton(
                    text: 'Send Reset Link',
                    onPressed: _handleResetPassword,
                  ),
          ),
          
          const SizedBox(height: 32),
          _animate(
            delay: 800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Remember your password? ",
                  style: TextStyle(color: Colors.black.withAlpha(140)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _animate({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Interval(delay / 2000 > 1.0 ? 0.9 : delay / 2000, 1.0, curve: Curves.easeOutCubic),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildIllustration() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _animate(
            delay: 100,
            child: Icon(
              Icons.security_outlined,
              size: 140,
              color: AppTheme.primaryColor.withAlpha(200),
            ),
          ),
          const SizedBox(height: 24),
          _animate(
            delay: 300,
            child: const Text(
              'Account Recovery',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _animate(
            delay: 500,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'Don\'t worry! It happens to the best of us. We\'ll help you get back to your dashboard in no time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black.withAlpha(140),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: SafeArea(
          child: ConstrainedCenter(
            maxWidth: 450,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GlassContainer(
                child: _buildResetForm(),
              ),
            ),
          ),
        ),
        tablet: SplitLayout(
          form: _buildResetForm(),
          illustration: _buildIllustration(),
        ),
      ),
    );
  }
}
