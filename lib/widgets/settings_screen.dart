import 'package:flutter/material.dart';
import '../app_constants.dart';
import '../l10n/app_localizations.dart';
import 'common/unfocus_on_tap.dart';
import 'settings/about_card.dart';
import 'settings/language_card.dart';
import 'settings/section_header.dart';
import 'settings/text_scale_card.dart';
import 'settings/palette_selector.dart';
import 'settings/theme_mode_selector.dart';
import 'settings/confirm_3d_tour_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: UnfocusOnTap(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.kScreenPadding,
            vertical: AppConstants.kCardBorderRadius,
          ),
          child: Column(
            children: [
              SectionHeader(title: l10n.appearance),
              const SizedBox(height: 6),
              const LanguageCard(),
              const SizedBox(height: AppConstants.kScreenPadding),
              const ThemeModeSelector(),
              const SizedBox(height: AppConstants.kScreenPadding),
              const PaletteSelector(),
              const SizedBox(height: AppConstants.kScreenPadding),
              const TextScaleCard(),
              const SizedBox(height: AppConstants.kScreenPadding),
              SectionHeader(title: l10n.behavior),
              const SizedBox(height: 6),
              const Confirm3dTourCard(),
              const SizedBox(height: AppConstants.kScreenPadding),
              SectionHeader(title: l10n.about),
              const SizedBox(height: 6),
              const AboutCard(),
            ],
          ),
        ),
      ),
    );
  }
}
