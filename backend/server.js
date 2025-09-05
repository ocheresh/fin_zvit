const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');
const { loadAccounts, saveAccounts } = require('./database');

const app = express();
const PORT = 8000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Routes

// GET /accounts - отримати всі рахунки
app.get('/accounts', async (req, res) => {
  try {
    const accounts = await loadAccounts();
    res.json(accounts);
  } catch (error) {
    res.status(500).json({ error: 'Помилка сервера' });
  }
});

// GET /accounts/:id - отримати рахунок по ID
app.get('/accounts/:id', async (req, res) => {
  try {
    const accounts = await loadAccounts();
    const account = accounts.find(a => a.id === req.params.id);
    
    if (!account) {
      return res.status(404).json({ error: 'Рахунок не знайдено' });
    }
    
    res.json(account);
  } catch (error) {
    res.status(500).json({ error: 'Помилка сервера' });
  }
});

// POST /accounts - створити новий рахунок
app.post('/accounts', async (req, res) => {
  try {
    const { accountNumber, legalName, edrpou, subordination } = req.body;
    
    // Валідація
    if (!accountNumber || !legalName || !edrpou || !subordination) {
      return res.status(400).json({ error: 'Всі поля обов\'язкові' });
    }
    
    if (edrpou.length !== 8 || !/^\d+$/.test(edrpou)) {
      return res.status(400).json({ error: 'ЄДРПОУ має містити 8 цифр' });
    }
    
    const accounts = await loadAccounts();
    
    // Перевірка на унікальність номера рахунку
    if (accounts.some(a => a.accountNumber === accountNumber)) {
      return res.status(400).json({ error: 'Рахунок з таким номером вже існує' });
    }
    
    const newAccount = {
      id: uuidv4(),
      accountNumber,
      legalName,
      edrpou,
      subordination,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    accounts.push(newAccount);
    await saveAccounts(accounts);
    
    res.status(201).json(newAccount);
  } catch (error) {
    res.status(500).json({ error: 'Помилка сервера' });
  }
});

// PUT /accounts/:id - оновити рахунок
app.put('/accounts/:id', async (req, res) => {
  try {
    const { accountNumber, legalName, edrpou, subordination } = req.body;
    
    // Валідація
    if (!accountNumber || !legalName || !edrpou || !subordination) {
      return res.status(400).json({ error: 'Всі поля обов\'язкові' });
    }
    
    if (edrpou.length !== 8 || !/^\d+$/.test(edrpou)) {
      return res.status(400).json({ error: 'ЄДРПОУ має містити 8 цифр' });
    }
    
    const accounts = await loadAccounts();
    const accountIndex = accounts.findIndex(a => a.id === req.params.id);
    
    if (accountIndex === -1) {
      return res.status(404).json({ error: 'Рахунок не знайдено' });
    }
    
    // Перевірка на унікальність номера рахунку (крім поточного)
    if (accounts.some(a => a.accountNumber === accountNumber && a.id !== req.params.id)) {
      return res.status(400).json({ error: 'Рахунок з таким номером вже існує' });
    }
    
    const updatedAccount = {
      ...accounts[accountIndex],
      accountNumber,
      legalName,
      edrpou,
      subordination,
      updatedAt: new Date().toISOString()
    };
    
    accounts[accountIndex] = updatedAccount;
    await saveAccounts(accounts);
    
    res.json(updatedAccount);
  } catch (error) {
    res.status(500).json({ error: 'Помилка сервера' });
  }
});

// DELETE /accounts/:id - видалити рахунок
app.delete('/accounts/:id', async (req, res) => {
  try {
    const accounts = await loadAccounts();
    const accountIndex = accounts.findIndex(a => a.id === req.params.id);
    
    if (accountIndex === -1) {
      return res.status(404).json({ error: 'Рахунок не знайдено' });
    }
    
    accounts.splice(accountIndex, 1);
    await saveAccounts(accounts);
    
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Помилка сервера' });
  }
});

// Запуск сервера
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Сервер запущено на http://0.0.0.0:${PORT}`);
});

// Обробка помилок
process.on('unhandledRejection', (error) => {
  console.error('Unhandled Rejection:', error);
  process.exit(1);
});