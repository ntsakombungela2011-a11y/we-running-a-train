import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/lobby/game_setup_preferences.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/view/play/time_control_modal.dart';
import 'package:lichess_mobile/src/widgets/variant_app_bar_title.dart';
import 'package:lichess_mobile/src/widgets/adaptive_choice_picker.dart';

class CreateGameWidget extends ConsumerWidget {
  const CreateGameWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playPrefs = ref.watch(gameSetupPreferencesProvider);
    final labelStyle = Theme.of(context).textTheme.labelLarge;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.timeControl, style: labelStyle),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    icon: Icon(playPrefs.timeIncrement.speed.icon),
                    label: Text(playPrefs.timeIncrement.display),
                    onPressed: () {
                      final double screenHeight = MediaQuery.sizeOf(
                        context,
                      ).height;
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        constraints: BoxConstraints(
                          maxHeight: screenHeight - (screenHeight / 10),
                        ),
                        builder: (BuildContext context) {
                          return TimeControlModal(
                            timeIncrement: playPrefs.timeIncrement,
                            onSelected: (choice) {
                              ref
                                  .read(gameSetupPreferencesProvider.notifier)
                                  .setTimeIncrement(choice);
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.variant, style: labelStyle),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    icon: playPrefs.customVariant != Variant.standard
                        ? Icon(playPrefs.customVariant.icon)
                        : null,
                    label: Text(playPrefs.customVariant.label(context.l10n)),
                    onPressed: () {
                      showChoicePicker(
                        context,
                        title: Text(context.l10n.variant),
                        choices: playSupportedVariants
                            .where((v) => v != Variant.fromPosition)
                            .toList(),
                        selectedItem: playPrefs.customVariant,
                        labelBuilder: (variant) => VariantLabel(variant),
                        onSelectedItemChanged: (Variant variant) {
                          ref
                              .read(gameSetupPreferencesProvider.notifier)
                              .setCustomVariant(variant);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
