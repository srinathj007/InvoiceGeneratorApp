import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'providers/locale_provider.dart';

import 'providers/theme_provider.dart';
import 'providers/business_provider.dart';

final localeProvider = LocaleProvider();
final themeProvider = ThemeProvider();
final businessProvider = BusinessProvider();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const InvoiceGenApp());
}

class InvoiceGenApp extends StatelessWidget {
  const InvoiceGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([localeProvider, themeProvider, businessProvider]),
      builder: (context, child) {
        return MaterialApp(
          title: 'ManaBill',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(themeProvider.selectedColor),
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('te'),
            Locale('hi'),
          ],
          home: const LoginScreen(),
        );
      },
    );
  }
}
