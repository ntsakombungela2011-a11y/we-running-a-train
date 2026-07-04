import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/app.dart';
import 'package:lichess_mobile/src/binding.dart';
import 'package:lichess_mobile/src/init.dart';
import 'package:lichess_mobile/src/intl.dart';
import 'package:lichess_mobile/src/model/common/service/sound_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  final lichessBinding = AppLichessBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await lichessBinding.preloadSharedPreferences();
  await preloadPieceImages();
  await initializeApp();
  await SoundService.initialize();

  final locale = await setupIntl(widgetsBinding);

  if (defaultTargetPlatform == TargetPlatform.android) {
    await androidDisplayInitialization(widgetsBinding);
  }

  runApp(
    ProviderScope(
      child: const AppInitializationScreen(),
    ),
  );
}
