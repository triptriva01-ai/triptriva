import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/data/initial_binding.dart';
import 'app/data/providers/token_store.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore any saved session before the first route is built, so the splash
  // screen already knows whether the user is signed in.
  final tokenStore = TokenStore();
  await tokenStore.init();
  Get.put<TokenStore>(tokenStore, permanent: true);

  runApp(
    GetMaterialApp(
      title: 'Trip Trivia',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      builder: (context, child) {
        // Honour the device's font-size setting, but stop the extreme end of
        // the range (Android allows 2x) from bursting fixed-height chrome such
        // as the bottom nav and button rows. Layouts flex up to this point.
        final scaler = MediaQuery.textScalerOf(context).clamp(
          minScaleFactor: 1,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    ),
  );
}
