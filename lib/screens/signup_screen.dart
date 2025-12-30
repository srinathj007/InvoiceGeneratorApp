import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/supabase_service.dart';
import '../widgets/responsive_layout.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: name,
      );
      if (mounted) {
        AppTheme.showToast(context, 'Registration successful! Please check your email for verification.');
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showError('An unexpected error occurred');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    AppTheme.showToast(context, _mapSupabaseError(message), isError: true);
  }

  String _mapSupabaseError(String error) {
    if (error.contains('User already registered')) {
      return 'Account already exists. Try signing in instead.';
    }
    return error;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildSignupForm() {
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
              child: const Icon(Icons.person_add_outlined, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 24),
          _animate(
            delay: 200,
            child: const Text(
              'Create Account',
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
              'Join our premium finance community',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black.withAlpha(140),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _animate(
            delay: 400,
            child: CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'John Doe',
              prefixIcon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 16),
          _animate(
            delay: 500,
            child: CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'name@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 16),
          _animate(
            delay: 600,
            child: CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
          ),
          
          const SizedBox(height: 24),
          _animate(
            delay: 700,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : CustomButton(
                    text: 'Create Account',
                    onPressed: _handleSignUp,
                  ),
          ),
          
          const SizedBox(height: 24),
          _animate(
            delay: 800,
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.black.withAlpha(20))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Or sign up with',
                    style: TextStyle(color: Colors.black.withAlpha(100), fontSize: 13),
                  ),
                ),
                Expanded(child: Divider(color: Colors.black.withAlpha(20))),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _animate(
            delay: 900,
            child: Row(
              children: [
                Expanded(
                  child: SocialButton(
                    text: 'Google',
                    icon: const Icon(Icons.g_mobiledata, size: 32, color: Color(0xFF4285F4)),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SocialButton(
                    text: 'Phone',
                    icon: const Icon(Icons.phone_android, size: 20, color: AppTheme.primaryColor),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          _animate(
            delay: 1100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
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
              Icons.rocket_launch_outlined,
              size: 140,
              color: AppTheme.primaryColor.withAlpha(200),
            ),
          ),
          const SizedBox(height: 24),
          _animate(
            delay: 300,
            child: const Text(
              'Join the Future',
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
                'Create an account and access premium financial tools designed for modern growth.',
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
                child: _buildSignupForm(),
              ),
            ),
          ),
        ),
        tablet: SplitLayout(
          form: _buildSignupForm(),
          illustration: _buildIllustration(),
        ),
      ),
    );
  }
}
