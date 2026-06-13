import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Marca tipográfica "Madame Jam" no estilo da logomarca.
///
/// Placeholder textual enquanto o asset oficial (fouet + espiga) não é
/// adicionado aos assets do projeto.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 40});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bakery_dining_outlined,
          size: fontSize,
          color: AppColors.champagne,
        ),
        const SizedBox(height: 8),
        Text(
          'Madame Jam',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: fontSize,
                color: AppColors.charcoal,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
