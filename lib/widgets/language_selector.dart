import 'package:flutter/material.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';
import '../main.dart';

class LanguageSelector extends StatelessWidget {
  final Color? color;

  const LanguageSelector({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = localeProvider.locale;

    return PopupMenuButton<Locale>(
      icon: Icon(Icons.language, color: color ?? Theme.of(context).colorScheme.primary),
      tooltip: l10n.selectLanguage,
      onSelected: (Locale locale) {
        localeProvider.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: _buildMenuItem('English', currentLocale.languageCode == 'en'),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('te'),
          child: _buildMenuItem('తెలుగు', currentLocale.languageCode == 'te'),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('hi'),
          child: _buildMenuItem('हिंदी', currentLocale.languageCode == 'hi'),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String label, bool isSelected) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (isSelected)
          const Icon(Icons.check, size: 20, color: Colors.green),
      ],
    );
  }
}
