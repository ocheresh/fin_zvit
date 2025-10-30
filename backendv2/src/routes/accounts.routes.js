import express from 'express';
import { getAll, getOne, create, update, remove } from '../controllers/accounts.controller.js';
const router = express.Router();
router.get('/', getAll);
router.get('/:id', getOne);
router.post('/', create);
router.put('/:id', update);
router.delete('/:id', remove);
export default router;
