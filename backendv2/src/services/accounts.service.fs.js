import fs from 'fs/promises';
import { nanoid } from 'nanoid';
import config from '../config.js';

async function read() {
  try {
    const s = await fs.readFile(config.dataFile, 'utf8');
    return JSON.parse(s);
  } catch (e) {
    if (e.code === 'ENOENT') return [];
    throw e;
  }
}
async function write(data) {
  await fs.mkdir('./src/data', { recursive: true });
  await fs.writeFile(config.dataFile, JSON.stringify(data, null, 2), 'utf8');
}

export default {
  async findAll() { return await read(); },
  async findById(id) { return (await read()).find(x => x.id === id) || null; },
  async create(payload) {
    const data = await read();
    const item = { id: nanoid(8), ...payload };
    data.unshift(item);
    await write(data);
    return item;
  },
  async update(id, payload) {
    const data = await read();
    const i = data.findIndex(x => x.id === id);
    if (i === -1) throw new Error('not found');
    data[i] = { ...data[i], ...payload, id };
    await write(data);
    return data[i];
  },
  async delete(id) {
    const data = await read();
    const i = data.findIndex(x => x.id === id);
    if (i === -1) throw new Error('not found');
    const removed = data.splice(i,1)[0];
    await write(data);
    return removed;
  }
};
