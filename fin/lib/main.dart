import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_service.dart';
import 'core/reposetories/account_repository.dart';
import 'core/config/app_config.dart';

import 'features/acoounts/data/accounts_remote_datasource.dart';
import 'features/acoounts/mvi/account_viewmodel.dart';

import 'screens/main_menu_screen.dart';

import 'core/reposetories/reference_repository.dart';
import 'features/references/data/references_remote_datasource.dart';
import 'features/references/mvi/reference_viewmodel.dart';

// --- Signers ---
import 'core/reposetories/signers_repository.dart';
import 'features/signers/data/signers_remote_datasource.dart';
import 'features/signers/mvi/signer_viewmodel.dart';

import 'core/reposetories/reestrprop_repository.dart';
import 'features/reestrprop/data/reestrprop_remote_datasource.dart';
import 'features/reestrprop/mvi/reestrprop_viewmodel.dart';

// ======= ДОДАНІ ІМПОРТИ ДЛЯ РОУТІВ (не змінюють існуючі) =======
import 'features/reestrprop/ui/reestrprop_list_page.dart';
import 'features/acoounts/ui/account_list_page.dart';
import 'features/signers/ui/signers_registry_page.dart';
import 'features/references/ui/reference_list_page.dart';
// ===============================================================

void main() {
  final api = ApiService(AppConfig.apiBaseUrl);

  // Accounts: RemoteDS -> Repo -> VM
  final accountsRemote = AccountsRemoteDataSource(api);
  final accountRepo = AccountRepository(accountsRemote);

  // References: RemoteDS -> Repo -> VM
  final referencesRemote = ReferencesRemoteDataSource(api);
  final referencesRepo = ReferenceRepository(remote: referencesRemote);

  // Signers: RemoteDS -> Repo -> VM
  final signersRemote = SignersRemoteDataSource(api);
  final signersRepo = SignersRepository(signersRemote);

  // ReestrProp: Repo(ApiService) -> RemoteDS(Repo) -> VM(DataSource)
  final reestrPropRepo = ReestrPropRepository(api);
  final reestrPropRemote = ReestrPropRemoteDataSource(reestrPropRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AccountViewModel(repo: accountRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ReferenceViewModel(repo: referencesRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => SignerViewModel(repo: signersRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ReestrPropViewModel(repo: reestrPropRemote),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinZvit',
      theme: ThemeData(primarySwatch: Colors.blue),

      // 🔹 Маршрути, щоб відкривати екрани за URL: /#/reestrprop, /#/accounts, ...
      initialRoute: '/',
      routes: {
        '/': (context) => const MainMenuScreen(),
        '/reestrprop': (context) => const ReestrPropListPage(),
        '/accounts': (context) => const AccountListPage(),
        '/signers': (context) => const SignersRegistryPage(),
        '/references': (context) => const ReferenceListPage(),
      },
    );
  }
}
