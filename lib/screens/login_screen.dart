import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/supabase_service.dart';
import 'signup_screen.dart';
import 'main_navigation.dart';
import 'forgot_password_screen.dart';
import '../widgets/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(email: email, password: password);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
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
    if (error.contains('Invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (error.contains('Email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    return error;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildLoginForm() {
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
              child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 24),
          _animate(
            delay: 200,
            child: const Text(
              'Welcome Back',
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
              'Sign in to your premium portfolio',
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
          const SizedBox(height: 16),
          _animate(
            delay: 500,
            child: CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
          ),
          
          _animate(
            delay: 600,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          _animate(
            delay: 700,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : CustomButton(
                    text: 'Sign In',
                    onPressed: _handleSignIn,
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
                    'Or continue with',
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
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.black.withAlpha(140)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  child: const Text(
                    'Sign Up',
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
              Icons.auto_graph_outlined,
              size: 140,
              color: AppTheme.primaryColor.withAlpha(200),
            ),
          ),
          const SizedBox(height: 24),
          _animate(
            delay: 300,
            child: const Text(
              'Secure Finance',
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
                'Experience your wealth grow in a safe and high-motion digital environment.',
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
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
        tablet: SplitLayout(
          form: _buildLoginForm(),
          illustration: _buildIllustration(),
        ),
      ),
    );
  }
}
