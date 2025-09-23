// routes/dict.js
"use strict";

const express = require("express");
const router = express.Router();
const dictController = require("../controllers/dictController");

// /api/dict/:dict
router.get("/:dict", dictController.list); // ?search=&limit=&offset=&order=name&dir=ASC
router.get("/:dict/:id", dictController.getById);
router.post("/:dict", dictController.create);
router.put("/:dict/:id", dictController.update);
router.delete("/:dict/:id", dictController.remove);

module.exports = router;
