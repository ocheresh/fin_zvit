const express = require('express');
const fs = require('fs').promises;
const path = require('path');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

const cors = require('cors');
app.use(cors());

app.use(bodyParser.json());

const dataDir = path.join(__dirname, 'data');

// --- Допоміжні функції ---
async function ensureDir(filePath) {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
}

async function loadJSON(filePath, defaultData = []) {
  try {
    const data = await fs.readFile(filePath, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    if (err.code === 'ENOENT') {
      await saveJSON(filePath, defaultData);
      return defaultData;
    }
    throw err;
  }
}

async function saveJSON(filePath, data) {
  await ensureDir(filePath);
  await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
}

// --- ACCOUNTS ---
const accountsPath = path.join(dataDir, 'accounts.json');

app.get('/accounts', async (req, res) => {
  try {
    const accounts = await loadJSON(accountsPath, []);
    res.json(accounts);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

app.post('/accounts', async (req, res) => {
  try {
    const account = req.body;
    account.id = account.id || Date.now().toString();
    const accounts = await loadJSON(accountsPath, []);
    accounts.push(account);
    await saveJSON(accountsPath, accounts);
    res.status(201).json(account);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// --- Оновлення рахунку ---
app.put('/accounts/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updatedAccount = req.body;
    let accounts = await loadJSON(accountsPath, []);
    const index = accounts.findIndex(a => a.id === id);
    if (index === -1) return res.status(404).send('Рахунок не знайдено');
    accounts[index] = { ...accounts[index], ...updatedAccount };
    await saveJSON(accountsPath, accounts);
    res.json(accounts[index]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// --- Видалення рахунку ---
app.delete('/accounts/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let accounts = await loadJSON(accountsPath, []);
    const newAccounts = accounts.filter(a => a.id !== id);
    if (newAccounts.length === accounts.length) return res.status(404).send('Рахунок не знайдено');
    await saveJSON(accountsPath, newAccounts);
    res.status(204).send(); // без контенту
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});


// --- REFERENCES ---
const referencesPath = path.join(dataDir, 'references.json');

// --- Get all categories ---
app.get('/references', async (req, res) => {
  try {
    const references = await loadJSON(referencesPath, {});
    res.json(references);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// --- Add new category ---
app.post('/references', async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ error: 'Потрібно вказати назву категорії' });

    const references = await loadJSON(referencesPath, {});
    if (references[name]) return res.status(400).json({ error: 'Категорія вже існує' });

    references[name] = [];
    await saveJSON(referencesPath, references);
    res.status(201).json({ message: 'Категорія додана' });
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// --- Delete category ---
app.delete('/references/:category', async (req, res) => {
  try {
    const { category } = req.params;
    const references = await loadJSON(referencesPath, {});
    if (!references[category]) return res.status(404).json({ error: 'Категорія не знайдена' });

    delete references[category];
    await saveJSON(referencesPath, references);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// --- Add item to category ---
app.post('/references/:category/items', async (req, res) => {
  try {
    const { category } = req.params;
    const { name, info } = req.body;

    if (!name) return res.status(400).json({ error: 'Потрібно вказати назву елемента' });

    const references = await loadJSON(referencesPath, {});
    if (!references[category]) return res.status(404).json({ error: 'Категорія не знайдена' });

    const id = Date.now().toString(); // простий унікальний ID
    references[category].push({ id, name, info: info || '' });

    await saveJSON(referencesPath, references);
    res.status(201).json({ message: 'Елемент додано', id });
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// --- Update item ---
app.put('/references/:category/items/:id', async (req, res) => {
  try {
    const { category, id } = req.params;
    const { name, info } = req.body;

    const references = await loadJSON(referencesPath, {});
    if (!references[category]) return res.status(404).json({ error: 'Категорія не знайдена' });

    const itemIndex = references[category].findIndex((item) => item.id === id);
    if (itemIndex === -1) return res.status(404).json({ error: 'Елемент не знайдено' });

    references[category][itemIndex] = { ...references[category][itemIndex], name, info: info || '' };
    await saveJSON(referencesPath, references);
    res.json({ message: 'Елемент оновлено' });
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// --- Delete item ---
app.delete('/references/:category/items/:id', async (req, res) => {
  try {
    const { category, id } = req.params;
    const references = await loadJSON(referencesPath, {});
    if (!references[category]) return res.status(404).json({ error: 'Категорія не знайдена' });

    const itemIndex = references[category].findIndex((item) => item.id === id);
    if (itemIndex === -1) return res.status(404).json({ error: 'Елемент не знайдено' });

    references[category].splice(itemIndex, 1);
    await saveJSON(referencesPath, references);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});


// --- PROP PLAN ASSIGN --


function getPlanFilePath(year, kpkv, fund) {
  const safeKpkv = String(kpkv).replace(/[^\w\d-]/g, '_');
  let safeFund = String(fund);
  if (safeFund === 'Загальний') safeFund = 'ZF';
  else if (safeFund === 'Спеціальний') safeFund = 'SF';
  else safeFund = safeFund.replace(/[^\w\d-]/g, '_');
  return path.join(dataDir, `prop_plan_assign_${year}_${safeKpkv}_${safeFund}.json`);
}


app.get('/prop-plan-assign/:year/:kpkv/:fund', async (req, res) => {
  try {
    const { year, kpkv, fund } = req.params;
    const plans = await loadJSON(getPlanFilePath(year, kpkv, fund), []);
    res.json(plans);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

app.post('/prop-plan-assign/:year/:kpkv/:fund', async (req, res) => {
  try {
    const { year, kpkv, fund } = req.params;
    const plan = req.body;
    plan.id = plan.id || Date.now().toString();
    const filePath = getPlanFilePath(year, kpkv, fund);
    const plans = await loadJSON(filePath, []);
    plans.push(plan);
    await saveJSON(filePath, plans);
    res.status(201).json(plan);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

app.put('/prop-plan-assign/:year/:kpkv/:fund/:id', async (req, res) => {
  try {
    const { year, kpkv, fund, id } = req.params;
    const updatedPlan = req.body;
    const filePath = getPlanFilePath(year, kpkv, fund);
    const plans = await loadJSON(filePath, []);
    const index = plans.findIndex(p => p.id === id);
    if (index === -1) return res.status(404).send('План не знайдено');
    plans[index] = { ...plans[index], ...updatedPlan };
    await saveJSON(filePath, plans);
    res.json(plans[index]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

app.delete('/prop-plan-assign/:year/:kpkv/:fund/:id', async (req, res) => {
  try {
    const { year, kpkv, fund, id } = req.params;
    const filePath = getPlanFilePath(year, kpkv, fund);
    let plans = await loadJSON(filePath, []);
    plans = plans.filter(p => p.id !== id);
    await saveJSON(filePath, plans);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// --- РЕЄСТР ПРОПОЗИЦІЙ ---

const year = new Date().getFullYear();
const propozPath = path.join(dataDir, `${year}_propoz.json`);

// Отримати всі пропозиції
app.get('/propoz', async (req, res) => {
  try {
    const propoz = await loadJSON(propozPath, []);
    res.json(propoz);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// Отримати наступний номер пропозиції
app.get('/propoz/next', async (req, res) => {
  try {
    const propoz = await loadJSON(propozPath, []);
    const lastNumber = propoz.length > 0 ? propoz[propoz.length - 1].number : 0;
    res.json({ next: lastNumber + 1 });
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// Додати пропозицію
app.post('/propoz', async (req, res) => {
  try {
    const { number, note, kpkv, fond } = req.body;
    let propoz = await loadJSON(propozPath, []);

    const date = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
    const newItem = { id: Date.now().toString(), number, note, date, kpkv, fond };
    propoz.push(newItem);

    await saveJSON(propozPath, propoz);
    res.status(201).json(newItem);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// Редагувати пропозицію
app.put('/propoz/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { number, note, kpkv, fond } = req.body;

    let propoz = await loadJSON(propozPath, []);
    const index = propoz.findIndex((p) => p.id === id);

    if (index === -1) {
      return res.status(404).send('Пропозицію не знайдено');
    }

    const date = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
    propoz[index] = { ...propoz[index], number, note, kpkv, fond, date };

    await saveJSON(propozPath, propoz);
    res.json(propoz[index]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// Видалити пропозицію
app.delete('/propoz/:id', async (req, res) => {
  try {
    const { id } = req.params;

    let propoz = await loadJSON(propozPath, []);
    const filtered = propoz.filter((p) => p.id !== id);

    if (filtered.length === propoz.length) {
      return res.status(404).send('Пропозицію не знайдено');
    }

    await saveJSON(propozPath, filtered);
    res.json({ message: 'Пропозицію видалено' });
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});


// // --- Результата пропозицій ---

//створюється нова база для тих пропозицій які пішли на підпис
function getResPropozFilePath(year, kpkv, fund) {
  const safeKpkv = String(kpkv).replace(/[^\w\d-]/g, '_');
  let safeFund = String(fund);
  if (safeFund === 'Загальний') safeFund = 'ZF';
  else if (safeFund === 'Спеціальний') safeFund = 'SF';
  else safeFund = safeFund.replace(/[^\w\d-]/g, '_');

  return path.join(dataDir, `res_plan_assign_${year}_${safeKpkv}_${safeFund}.json`);
}

// --- ФАБРИКИ ---
const monthNames = [
  "Січень", "Лютий", "Березень", "Квітень", "Травень", "Червень",
  "Липень", "Серпень", "Вересень", "Жовтень", "Листопад", "Грудень"
];

function createResPropozRow(item) {
  const monthsObj = monthNames.reduce((acc, m, i) => {
    acc[m] = item.months[i] || 0;
    return acc;
  }, {});
  const vsogo = Object.values(monthsObj).reduce((sum, val) => sum + val, 0);
  return {
    vidomchyiKod: item.accountId.split(' / ')[0],
    nameRozporyad: item.legalName,
    nameVytrat: item.kekvName || "",
    kekv: item.kekvId,
    vsogo,
    months: monthsObj,
    notes: item.additionalInfo || "",
  };
}

function createResPropoz(id, year, items) {
  const currentMonth = monthNames[new Date().getMonth()];
  return {
    id,
    year,
    month: currentMonth,
    rows: items.map(createResPropozRow),
    approved: false,
    filteredRows: null
  };
}

// --- ROUTES CRUD ---

// Отримати всі пропозиції
app.get('/res_plan_assign/:year/:kpkv/:fond', async (req, res) => {
  try {
    const { year, kpkv, fond } = req.params;
    const filePath = getResPropozFilePath(year, kpkv, fond);
    const data = await loadJSON(filePath, []);
    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка при завантаженні respropoz');
  }
});

// Додати нову пропозицію
app.post('/res_plan_assign/:year/:kpkv/:fond', async (req, res) => {
  try {
    const { items, year, kpkv, fond } = req.body;
    if (!items || !year || !kpkv || !fond) {
      return res.status(400).send('Необхідні параметри відсутні');
    }

    const filePath = getResPropozFilePath(year, kpkv, fond);
    let resPropoz = await loadJSON(filePath, []);

    const newProposal = createResPropoz(resPropoz.length + 1, year, items);

    resPropoz.push(newProposal);
    await saveJSON(filePath, resPropoz);

    res.status(201).json(newProposal);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка при створенні пропозиції');
  }
});

// Оновити пропозицію за id
app.put('/res_plan_assign/:year/:kpkv/:fond/:id', async (req, res) => {
  try {
    const { year, kpkv, fond, id } = req.params;
    const updatedData = req.body;

    const filePath = getResPropozFilePath(year, kpkv, fond);
    let resPropoz = await loadJSON(filePath, []);

    const index = resPropoz.findIndex(p => p.id.toString() === id);
    if (index === -1) return res.status(404).send('Пропозицію не знайдено');

    // Оновлюємо тільки дозволені поля
    if (updatedData.items) {
      resPropoz[index].rows = updatedData.items.map(createResPropozRow);
      resPropoz[index].month = monthNames[new Date().getMonth()];
      resPropoz[index].year = updatedData.year || resPropoz[index].year;
    }
    if (typeof updatedData.approved === 'boolean') {
      resPropoz[index].approved = updatedData.approved;
    }
    if (updatedData.filteredRows !== undefined) {
      resPropoz[index].filteredRows = updatedData.filteredRows;
    }

    await saveJSON(filePath, resPropoz);
    res.json(resPropoz[index]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка при оновленні пропозиції');
  }
});

// Видалити пропозицію
app.delete('/res_plan_assign/:year/:kpkv/:fond/:id', async (req, res) => {
  try {
    const { year, kpkv, fond, id } = req.params;
    const filePath = getResPropozFilePath(year, kpkv, fond);

    let resPropoz = await loadJSON(filePath, []);
    const filtered = resPropoz.filter(p => p.id.toString() !== id);

    if (filtered.length === resPropoz.length) return res.status(404).send('Пропозицію не знайдено');

    await saveJSON(filePath, filtered);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка при видаленні пропозиції');
  }
});



// // --- Результата пропозицій ---

// //створюється нова база для тих пропозицій які пішли на підпис
// function getResPropozFilePath(year, kpkv, fund) {
//   const safeKpkv = String(kpkv).replace(/[^\w\d-]/g, '_');
//   let safeFund = String(fund);
//   if (safeFund === 'Загальний') safeFund = 'ZF';
//   else if (safeFund === 'Спеціальний') safeFund = 'SF';
//   else safeFund = safeFund.replace(/[^\w\d-]/g, '_');

//   return path.join(dataDir, `res_plan_assign_${year}_${safeKpkv}_${safeFund}.json`);
// }



// // Отримати дані результатів пропозицій
// app.get('/res_plan_assign/:year/:kpkv/:fond', async (req, res) => {
//   try {
//     const { year, kpkv, fond } = req.params;
//     const filePath = getResPropozFilePath(year, kpkv, fond);
//     const data = await loadJSON(filePath, []);
//     // print(data)
//     res.json(data);
//   } catch (err) {
//     console.error(err);
//     res.status(500).send('Помилка при завантаженні respropoz');
//   }
// });

// // Додати записи у результат пропозицій
// app.post('/res_plan_assign/:year/:kpkv/:fond', async (req, res) => {
//   try {
//     const { numberPropose, items, year, kpkv, fond } = req.body;
//     if (!numberPropose || !items || !year || !kpkv || !fond) {
//       return res.status(400).send('Необхідні параметри відсутні');
//     }

//     const filePath = getResPropozFilePath(year, kpkv, fond);
//     let resPropoz = await loadJSON(filePath, []);

//     // Генеруємо новий запис як "пропозицію"
//     const monthNames = [
//       "Січень", "Лютий", "Березень", "Квітень", "Травень", "Червень",
//       "Липень", "Серпень", "Вересень", "Жовтень", "Листопад", "Грудень"
//     ];

//     const newProposal = {
//       id: resPropoz.length + 1,
//       year,
//       month: monthNames[new Date().getMonth()],
//       rows: items.map((item) => {
//         const vsogo = item.months.reduce((sum, val) => sum + val, 0);
//         const monthsObj = monthNames.reduce((acc, m, i) => {
//           acc[m] = item.months[i] || 0;
//           return acc;
//         }, {});
//         return {
//           vidomchyiKod: item.accountId.split(' / ')[0],
//           nameRozporyad: item.legalName,
//           nameVytrat: item.kekvName || "Невідомо",
//           kekv: item.kekvId,
//           vsogo,
//           months: monthsObj,
//           notes: item.additionalInfo || "",
//         };
//       }),
//       approved: false,
//       filteredRows: null,
//     };

//     resPropoz.push(newProposal);
//     await saveJSON(filePath, resPropoz);

//     res.status(201).json(newProposal);
//   } catch (err) {
//     console.error(err);
//     res.status(500).send('Помилка сервера при збереженні respropoz');
//   }
// });




// --- СТАРТ СЕРВЕРА ---
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Сервер запущено на http://0.0.0.0:${PORT}`);
});

process.on('unhandledRejection', (error) => {
  console.error('Unhandled Rejection:', error);
});
