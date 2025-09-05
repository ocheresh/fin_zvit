const fs = require('fs').promises;
const path = require('path');

const dataPath = path.join(__dirname, 'data', 'accounts.json');

// Завантажити рахунки з файлу
async function loadAccounts() {
  try {
    const data = await fs.readFile(dataPath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    // Якщо файл не існує, повернути пустий масив
    if (error.code === 'ENOENT') {
      return [];
    }
    throw error;
  }
}

// Зберегти рахунки у файл
async function saveAccounts(accounts) {
  try {
    await fs.mkdir(path.dirname(dataPath), { recursive: true });
    await fs.writeFile(dataPath, JSON.stringify(accounts, null, 2), 'utf8');
  } catch (error) {
    throw error;
  }
}

module.exports = { loadAccounts, saveAccounts };