// controllers/dictController.js
"use strict";

const { Op } = require("sequelize");
const models = require("../models"); // стандартний index.js від sequelize-cli

// БЕЗПЕКА: дозволяємо тільки ці довідники
const ALLOWED = {
  kpkv: "Kpkv",
  fund: "Fund",
  direction: "Direction",
  kekv: "Kekv",
  kekvdet: "KekvDet",
  subordination: "Subordination",
  measure: "Measure",
  account: "Account", // якщо треба в універсальному роутері (можеш прибрати)
};

function getModelOrThrow(dictParam) {
  const key = String(dictParam || "").toLowerCase();
  const modelName = ALLOWED[key];
  if (!modelName || !models[modelName]) {
    const err = new Error(`Unknown dictionary: '${dictParam}'`);
    err.status = 404;
    throw err;
  }

  return models[modelName];
}

function parsePagination(req) {
  const limit = Math.min(
    Math.max(parseInt(req.query.limit ?? "20", 10), 1),
    200
  );
  const offset = Math.max(parseInt(req.query.offset ?? "0", 10), 0);
  const order = (req.query.order || "name").toString();
  const dir =
    (req.query.dir || "ASC").toString().toUpperCase() === "DESC"
      ? "DESC"
      : "ASC";
  return { limit, offset, order, dir };
}

// controllers/dictController.js (фрагмент)
exports.list = async (req, res) => {
  try {
    const Model = getModelOrThrow(req.params.dict);

    const { limit, offset, order, dir } = parsePagination(req);
    const search = (req.query.search || "").trim();

    const where = {};
    const include = [];

    // універсальний пошук по name (якщо є таке поле)
    if (search && Model.rawAttributes?.name) {
      where.name = { [Op.like]: `%${search}%` };
    }

    // спеціальний випадок: Account — пошук по кількох полях + підтягуємо підпорядкування
    if (Model.name === "Account") {
      if (search) {
        where[Op.or] = [
          { accountNumber: { [Op.like]: `%${search}%` } },
          { rozporiadNumber: { [Op.like]: `%${search}%` } },
          { legalName: { [Op.like]: `%${search}%` } },
          { edrpou: { [Op.like]: `%${search}%` } },
          { additionalInfo: { [Op.like]: `%${search}%` } },
        ];
      }
      // підтягуємо назву підпорядкування
      include.push({
        model: require("../models").Subordination,
        attributes: ["id", "name"],
      });
    }
    // основний запит
    const result = await Model.findAndCountAll({
      where,
      include,
      limit,
      offset,
      order: Model.rawAttributes[order] ? [[order, dir]] : [["id", "ASC"]],
    });

    // розплющуємо include і робимо plain-об’єкти
    const rows = result.rows.map((row) => {
      const plain = row.get({ plain: true });
      if (Model.name === "Account" && plain.Subordination) {
        plain.subordinationId = plain.Subordination.id;
        plain.subordination = plain.Subordination.name;
        delete plain.Subordination;
      }
      return plain;
    });
    console.log(result);

    // ▼ ГОЛОВНА ЗМІНА: повертаємо ПЛОСКИЙ МАСИВ (для Flutter)
    // count кладемо в заголовок, щоб не загубити інформацію.
    res.set("X-Total-Count", String(result.count || 0));
    return res.json(rows);

    // Якщо колись треба буде "старий" формат:
    // res.json({ rows, count: result.count, limit, offset });
  } catch (e) {
    res.status(e.status || 500).json({ error: e.message || "Server error" });
  }
};

exports.getById = async (req, res) => {
  try {
    const Model = getModelOrThrow(req.params.dict);
    const row = await Model.findByPk(req.params.id);
    if (!row) return res.status(404).json({ error: "Not found" });
    res.json(row);
  } catch (e) {
    res.status(e.status || 500).json({ error: e.message || "Server error" });
  }
};

exports.create = async (req, res) => {
  try {
    const Model = getModelOrThrow(req.params.dict);

    // Невелика валідація: якщо у моделі є name, вимагай його
    if (Model.rawAttributes.name && !req.body.name) {
      return res.status(400).json({ error: "Field 'name' is required" });
    }

    const created = await Model.create(req.body);
    res.status(201).json(created);
  } catch (e) {
    // ловимо унікальні ключі та інші
    if (e.name === "SequelizeUniqueConstraintError") {
      return res.status(409).json({
        error: "Duplicate value",
        details: e.errors?.map((er) => er.message),
      });
    }
    if (e.name === "SequelizeForeignKeyConstraintError") {
      return res
        .status(422)
        .json({ error: "Invalid reference (FK)", details: e.message });
    }
    res.status(500).json({ error: e.message || "Server error" });
  }
};

exports.update = async (req, res) => {
  try {
    const Model = getModelOrThrow(req.params.dict);
    const id = req.params.id;
    const row = await Model.findByPk(id);
    if (!row) return res.status(404).json({ error: "Not found" });

    await row.update(req.body);
    res.json(row);
  } catch (e) {
    if (e.name === "SequelizeUniqueConstraintError") {
      return res.status(409).json({
        error: "Duplicate value",
        details: e.errors?.map((er) => er.message),
      });
    }
    if (e.name === "SequelizeForeignKeyConstraintError") {
      return res
        .status(422)
        .json({ error: "Invalid reference (FK)", details: e.message });
    }
    res.status(500).json({ error: e.message || "Server error" });
  }
};

exports.remove = async (req, res) => {
  try {
    const Model = getModelOrThrow(req.params.dict);
    const id = req.params.id;
    const row = await Model.findByPk(id);
    if (!row) return res.status(404).json({ error: "Not found" });

    await row.destroy();
    res.json({ ok: true });
  } catch (e) {
    // Якщо не можна видалити через FK — повернемо 409
    if (e.name === "SequelizeForeignKeyConstraintError") {
      return res.status(409).json({
        error: "Record is in use (FK constraint)",
        details: e.message,
      });
    }
    res.status(500).json({ error: e.message || "Server error" });
  }
};
