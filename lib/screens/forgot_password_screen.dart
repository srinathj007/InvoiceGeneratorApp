import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/supabase_service.dart';
import '../widgets/responsive_layout.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';
import '../widgets/app_logo.dart';
import '../widgets/language_selector.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(email);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              email: email,
              type: OTPVerifyType.recovery,
              newPassword: password,
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showToast(e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showToast(e.toString(), isError: true);
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
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          const AppLogo(size: 80, fontSize: 28),
          const SizedBox(height: 32),
          Text(
            l10n.resetPassword,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            controller: _emailController,
            label: l10n.email,
            hint: 'name@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'New Password',
            hint: 'Enter your new password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: l10n.sendResetLink,
                  onPressed: _handleResetPassword,
                ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.rememberPassword),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  l10n.signIn,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.security_outlined,
            size: 140,
            color: Theme.of(context).colorScheme.primary.withAlpha(200),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.accountRecovery,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.recoveryMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      body: SafeArea(
        child: Stack(
          children: [
            ResponsiveLayout(
              mobile: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _buildResetForm(),
                  ),
                ),
              ),
              tablet: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: _buildResetForm(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: _buildIllustration(),
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              top: 10,
              right: 10,
              child: LanguageSelector(),
            ),
          ],
        ),
      ),
    );
  }
}
