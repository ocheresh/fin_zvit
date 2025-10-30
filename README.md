# fin_zvit

accounts-backend-v2/
├─ package.json
├─ src/
│ ├─ server.js
│ ├─ config.js
│ ├─ routes/
│ │ └─ accounts.routes.js
│ ├─ controllers/
│ │ └─ accounts.controller.js
│ ├─ services/
│ │ └─ accounts.service.fs.js
│ ├─ models/
│ │ └─ account.model.js
│ └─ data/
│ └─ accounts.json

lib/
├─ main.dart
├─ core/
│ ├─ api/
│ │ └─ api_service.dart
│ ├─ models/
│ │ └─ account.dart
│ └─ repositories/
│ └─ account_repository.dart
├─ features/
│ └─ accounts/
│ ├─ data/
│ │ └─ accounts_remote_datasource.dart
│ ├─ mvi/
│ │ ├─ account_intent.dart
│ │ ├─ account_state.dart
│ │ └─ account_viewmodel.dart
│ └─ ui/
│ └─ account_list_page.dart
