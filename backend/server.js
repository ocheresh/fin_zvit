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

app.get('/references', async (req, res) => {
  try {
    const references = await loadJSON(referencesPath, {});
    res.json(references);
  } catch (err) {
    console.error(err);
    res.status(500).send('Помилка сервера');
  }
});

// --- PROP PLAN ASSIGN ---
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

const propozPath = path.join(dataDir, 'propoz.json');

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
    const { number, note } = req.body;
    let propoz = await loadJSON(propozPath, []);

    const newItem = { id: Date.now().toString(), number, note };
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
    const { number, note } = req.body;

    let propoz = await loadJSON(propozPath, []);
    const index = propoz.findIndex((p) => p.id === id);

    if (index === -1) {
      return res.status(404).send('Пропозицію не знайдено');
    }

    propoz[index] = { ...propoz[index], number, note };
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


// --- СТАРТ СЕРВЕРА ---
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Сервер запущено на http://0.0.0.0:${PORT}`);
});

process.on('unhandledRejection', (error) => {
  console.error('Unhandled Rejection:', error);
});
