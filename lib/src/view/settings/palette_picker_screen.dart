import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/styles/palettes.dart';
import 'package:lichess_mobile/src/model/settings/general_preferences.dart';
import 'package:lichess_mobile/src/widgets/list.dart';

class PalettePickerScreen extends ConsumerWidget {
  const PalettePickerScreen({super.key});

  static Route<void> buildRoute() {
    return MaterialPageRoute(builder: (context) => const PalettePickerScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPaletteId = ref
        .watch(generalPreferencesProvider)
        .selectedPaletteId;

    return Scaffold(
      appBar: AppBar(title: const Text('Themes')),
      body: ListView(
        children: [
          for (final category in PaletteCategory.values)
            _CategorySection(
              category: category,
              selectedPaletteId: selectedPaletteId,
            ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.selectedPaletteId,
  });

  final PaletteCategory category;
  final String selectedPaletteId;

  @override
  Widget build(BuildContext context) {
    final palettes = allPalettes.where((p) => p.category == category).toList();
    if (palettes.isEmpty) return const SizedBox.shrink();

    return ListSection(
      header: Text(category.label),
      children: palettes.map((palette) {
        return Consumer(
          builder: (context, ref, child) {
            return ListTile(
              title: Text(palette.name),
              trailing: palette.id == selectedPaletteId
                  ? const Icon(Icons.check)
                  : null,
              leading: _PalettePreview(palette: palette),
              onTap: () {
                ref
                    .read(generalPreferencesProvider.notifier)
                    .setPalette(palette.id);
              },
            );
          },
        );
      }).toList(),
    );
  }
}

class _PalettePreview extends StatelessWidget {
  const _PalettePreview({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: ClipOval(
        child: Row(
          children: [
            for (final color in palette.colors)
              Expanded(child: Container(color: color)),
          ],
        ),
      ),
    );
  }
}
