import 'package:flutter/material.dart';
import 'package:junk_and_gems/components/language_toggle_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showLanguageToggle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.showBackButton = true,
    this.onBackPressed,
    this.showLanguageToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      actions: [
        // Additional actions first (if any)
        if (additionalActions != null) ...additionalActions!,
        
        // Language toggle always appears
        if (showLanguageToggle)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: LanguageToggleButton(),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}