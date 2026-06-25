import 'package:flutter/material.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';
import 'package:neroflac/widgets/liquid_glass_surface.dart';

/// Wiza-styled background for grouped cards. Glass card variant lets the
/// page gradient bleed through the surface for the Prisma + Liquid Glass
/// aesthetic.
Color settingsGroupColor(BuildContext context) {
  final nero = NeroTheme.of(context);
  return nero.glassCard;
}

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  const SettingsGroup({super.key, required this.children, this.margin});

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);

    return LiquidGlassSurface(
      variant: GlassVariant.card,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: BorderRadius.circular(nero.radiusLg),
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool enabled;
  final Widget? titleTrailing;

  const SettingsItem({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.enabled = true,
    this.titleTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);

    final content = InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 20,
                  color: enabled ? nero.carbonInk : nero.fog),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: enabled
                                    ? nero.carbonInk
                                    : nero.fog,
                              ),
                        ),
                      ),
                      ?titleTrailing,
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: enabled ? nero.slate : nero.fog,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: nero.glassBorderSubtle,
            indent: icon != null ? 50 : 16,
            endIndent: 16,
          ),
      ],
    );
  }
}

class SettingsSwitchItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;
  final bool enabled;
  final Widget? titleTrailing;

  const SettingsSwitchItem({
    super.key,
    this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
    this.enabled = true,
    this.titleTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);

    final content = InkWell(
      onTap: (onChanged == null || !enabled) ? null : () => onChanged!(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 20,
                  color: enabled ? nero.carbonInk : nero.fog),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: enabled
                                    ? nero.carbonInk
                                    : nero.fog,
                              ),
                        ),
                      ),
                      ?titleTrailing,
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: enabled ? nero.slate : nero.fog,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: nero.glassBorderSubtle,
            indent: icon != null ? 50 : 16,
            endIndent: 16,
          ),
      ],
    );
  }
}

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: nero.slate,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}