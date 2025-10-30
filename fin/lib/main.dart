import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Core / Data ---
import 'core/api/api_service.dart';
// якщо у тебе папка реально називається "reposetories" (з помилкою), лишай так:
import 'core/reposetories/account_repository.dart';
// якщо ВЖЕ перейменував на "repositories", імпорт має бути:
// import 'core/repositories/account_repository.dart';
import 'core/config/app_config.dart';

// --- Features: Accounts ---
import 'features/acoounts/data/accounts_remote_datasource.dart';
// якщо виправив назву папки:
// import 'features/accounts/data/accounts_remote_datasource.dart';
import 'features/acoounts/mvi/account_viewmodel.dart';
// виправлена папка:
// import 'features/accounts/mvi/account_viewmodel.dart';

// --- UI ---
import 'screens/main_menu_screen.dart'; // твій MainMenuScreen
// або якщо lies elsewhere: import '.../main_menu_screen.dart';

void main() {
  // Для веб/десктопа:
  final api = ApiService(AppConfig.apiBaseUrl);
  // Для Android емулятора використовуй: ApiService('http://10.0.2.2:3001');

  final remote = AccountsRemoteDataSource(api);
  final repo = AccountRepository(remote);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountViewModel(repo: repo)),
        // додаватимеш інші VM тут (довідники, пропозиції тощо)
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
      home: const MainMenuScreen(), // ← тепер головне меню стартове
    );
  }
}
