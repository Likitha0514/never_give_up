import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeverGiveUpLogo extends StatelessWidget {
  const NeverGiveUpLogo({
    super.key,
    this.compact = false,
    this.showTagline = true,
  });

  final bool compact;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 18.0 : 34.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 34 : 58,
              height: compact ? 34 : 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.orange],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .18),
                    blurRadius: compact ? 10 : 22,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                size: compact ? 20 : 34,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'NEVER\nGIVE UP',
              textAlign: TextAlign.left,
              style: TextStyle(
                height: .9,
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 14),
          Text(
            'SMALL STEPS. STRONGER YOU.',
            style: TextStyle(
              fontSize: compact ? 8 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.1,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55),
            ),
          ),
        ],
      ],
    );
  }
}
