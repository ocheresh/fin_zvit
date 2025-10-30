import accountsService from '../services/accounts.service.fs.js';
import { validateAccountPayload } from '../models/account.model.js';

export const getAll = async (req, res) => {
  try { const data = await accountsService.findAll(); res.json(data); }
  catch (e) { res.status(500).json({ error: e.message }); }
};

export const getOne = async (req, res) => {
  try { const it = await accountsService.findById(req.params.id); if(!it) return res.status(404).json({ error: 'not found' }); res.json(it); }
  catch (e) { res.status(500).json({ error: e.message }); }
};

export const create = async (req, res) => {
  try {
    validateAccountPayload(req.body);
    const created = await accountsService.create(req.body);
    res.status(201).json(created);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
};

export const update = async (req, res) => {
  try {
    const updated = await accountsService.update(req.params.id, req.body);
    res.json(updated);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
};

export const remove = async (req, res) => {
  try {
    await accountsService.delete(req.params.id);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};
