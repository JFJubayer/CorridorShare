import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Spacing scale, 8px base.
abstract final class Gap {
  static const xs = SizedBox(height: 4, width: 4);
  static const sm = SizedBox(height: 8, width: 8);
  static const md = SizedBox(height: 16, width: 16);
  static const lg = SizedBox(height: 24, width: 24);
  static const xl = SizedBox(height: 32, width: 32);
}

/// Section title with an optional trailing action. Plain text, no eyebrow.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title, style: context.tt.titleMedium)),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              foregroundColor: context.cs.onSurfaceVariant,
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}

/// Label on the left, value on the right. Groups are separated by hairlines
/// via [KeyValueGroup], never by nested boxes.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.label, this.value, {super.key, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.tt.bodyMedium)),
          Text(
            value,
            style: context.tt.titleSmall?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class KeyValueGroup extends StatelessWidget {
  const KeyValueGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(),
          children[i],
        ],
      ],
    );
  }
}

enum StatusTone { neutral, ok, danger, pending }

/// Icon + text status indicator. Replaces tinted pill badges.
class StatusText extends StatelessWidget {
  const StatusText(this.label, {super.key, this.tone = StatusTone.neutral, this.icon});

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = switch (tone) {
      StatusTone.ok => colors.ok,
      StatusTone.danger => colors.danger,
      StatusTone.pending => context.cs.onSurface,
      StatusTone.neutral => context.cs.onSurfaceVariant,
    };
    final glyph = icon ??
        switch (tone) {
          StatusTone.ok => Icons.check_circle_outline,
          StatusTone.danger => Icons.error_outline,
          StatusTone.pending => Icons.schedule,
          StatusTone.neutral => Icons.circle_outlined,
        };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(glyph, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: context.tt.labelMedium?.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Flat surface container. Use only when grouping genuinely needs a boundary.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Material(
      color: context.cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

/// Inline, non-blocking notice. Used for mode limits and warnings.
class InlineNotice extends StatelessWidget {
  const InlineNotice(this.message, {super.key, this.tone = StatusTone.neutral});

  final String message;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      StatusTone.danger => context.appColors.danger,
      StatusTone.ok => context.appColors.ok,
      _ => context.cs.onSurfaceVariant,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: context.tt.bodySmall?.copyWith(color: color)),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: context.cs.onSurfaceVariant),
            Gap.md,
            Text(title, style: context.tt.titleMedium, textAlign: TextAlign.center),
            Gap.sm,
            Text(message, style: context.tt.bodyMedium, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              Gap.lg,
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer-free skeleton rows that mirror a list row's shape.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 4, this.padding = const EdgeInsets.all(16)});

  final int rows;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.skeleton;
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
    return Padding(
      padding: padding,
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  Gap.md,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bar(double.infinity, 12),
                        Gap.sm,
                        bar(160, 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Initials avatar in a neutral surface. No tinted rings.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.text, {super.key, this.radius = 18, this.image});

  final String text;
  final double radius;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: context.cs.surfaceContainerHigh,
      foregroundColor: context.cs.onSurface,
      backgroundImage: image,
      child: image == null
          ? Text(
              text.isEmpty ? '?' : text.characters.first.toUpperCase(),
              style: context.tt.titleSmall?.copyWith(fontSize: radius * 0.75),
            )
          : null,
    );
  }
}
