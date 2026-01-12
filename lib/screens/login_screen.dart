import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/supabase_service.dart';
import '../services/profile_service.dart';
import 'signup_screen.dart';
import 'main_navigation.dart';
import 'profile_screen.dart';
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
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final profileService = ProfileService();
      final profiles = await profileService.getProfiles();
      if (mounted) {
        if (profiles.isEmpty) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(isNewBusiness: true, isMandatory: true),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      }
    } else {
      if (mounted) setState(() => _isCheckingAuth = false);
    }
  }

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
        // Check if user has any profiles
        final profileService = ProfileService();
        final profiles = await profileService.getProfiles();
        
        if (mounted) {
          if (profiles.isEmpty) {
            // No profile found - mandatory setup
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(isNewBusiness: true, isMandatory: true),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainNavigation()),
            );
          }
        }
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
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.welcomeBack,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.signInToPortfolio,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

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
            hint: l10n.enterPassword,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
          ),
          
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );
              },
              child: Text(
                l10n.forgotPassword,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: l10n.signIn,
                  onPressed: _handleSignIn,
                ),
          
          const SizedBox(height: 24),


           


          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.dontHaveAccount,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: Text(
                  l10n.signUp,
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
            Icons.auto_graph_outlined,
            size: 140,
            color: Theme.of(context).colorScheme.primary.withAlpha(200),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.secureFinance,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              l10n.secureFinanceDesc,
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
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: ResponsiveLayout(
        mobile: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildLoginForm(),
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
                    child: _buildLoginForm(),
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
