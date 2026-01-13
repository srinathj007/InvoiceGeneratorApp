import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/supabase_service.dart';
import '../widgets/responsive_layout.dart';
import 'profile_screen.dart';

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
    final l10n = AppLocalizations.of(context)!;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError(l10n.fillAllFields);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: name,
      );
      if (mounted) {
        if (response.session != null) {
          // Auto signed in - go to profile creation
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(isNewBusiness: true, isMandatory: true),
            ),
            (route) => false,
          );
        } else {
          // Verification required?
          AppTheme.showToast(context, l10n.registrationSuccess);
          Navigator.pop(context);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showError(l10n.unexpectedError);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    AppTheme.showToast(context, _mapSupabaseError(message), isError: true);
  }

  String _mapSupabaseError(String error) {
    // If we're already passing a localized string (like fillAllFields or unexpectedError), just return it
    // But wait, fillAllFields is passed as 'message' to _showError.
    // _mapSupabaseError receives it.
    // The check `error.contains('User already registered')` is for Supabase English error messages.
    // So we need to match the backend error (usually English) and replace with Localized string.
    
    final l10n = AppLocalizations.of(context)!;
    if (error.contains('User already registered')) {
      return l10n.accountExists;
    }
    // If it's one of our localized strings already (unlikely unless logic flow is mixed), or a backend error we show raw.
    // We should probably just return error.
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              'assets/logo_with_name.png',
              height: 60,
              width: 200,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_add_outlined, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.createAccount,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            controller: _nameController,
            label: l10n.fullName,
            hint: l10n.enterName,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: l10n.emailAddress,
            hint: l10n.enterEmail,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: l10n.password,
            hint: l10n.createPassword,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
          ),
          
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: l10n.createAccount,
                  onPressed: _handleSignUp,
                ),
          

           


          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.alreadyHaveAccount),
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
    );
  }

  Widget _buildIllustration() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            size: 120,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.joinFuture,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.joinFutureDesc,
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
      body: ResponsiveLayout(
        mobile: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildSignupForm(),
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
                    child: _buildSignupForm(),
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
    );
  }
}
