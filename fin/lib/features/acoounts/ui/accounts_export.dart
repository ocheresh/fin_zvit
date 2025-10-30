import 'dart:io';
import 'package:excel/excel.dart' as ex;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../../../../core/models/account.dart';

/// Повертає шлях збереження (mobile/desktop) або null (web).
Future<String?> exportAccountsToExcel(List<Account> accounts) async {
  // Створюємо книгу з дефолтним аркушем "Sheet1"
  final book = ex.Excel.createExcel();
  const sheetName = 'Accounts';

  // Перейменовуємо "Sheet1" → "Accounts"
  book.rename('Sheet1', sheetName);
  final sheet = book[sheetName];

  // Додаємо заголовки
  sheet.appendRow([
    ex.TextCellValue("Особовий рахунок"),
    ex.TextCellValue("Номер розпорядника коштів"),
    ex.TextCellValue("Найменування"),
    ex.TextCellValue("ЄДРПОУ"),
    ex.TextCellValue("Підпорядкованість"),
    ex.TextCellValue("Додаткова інформація"),
  ]);

  // Додаємо рядки
  for (final a in accounts) {
    sheet.appendRow([
      ex.TextCellValue(a.accountNumber),
      ex.TextCellValue(a.rozporiadNumber),
      ex.TextCellValue(a.legalName),
      ex.TextCellValue(a.edrpou.isEmpty ? '00000000' : a.edrpou),
      ex.TextCellValue(
        a.subordination?.isNotEmpty == true ? a.subordination! : 'Інше',
      ),
      ex.TextCellValue(a.additionalInfo.isEmpty ? '-' : a.additionalInfo),
    ]);
  }

  // Web: автозавантаження файлу
  if (kIsWeb) {
    book.save(fileName: 'accounts.xlsx');
    return null;
  }

  // Mobile/Desktop: збереження у Documents
  final bytes = book.save()!;
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/accounts.xlsx')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  return file.path;
}
