"use strict";

module.exports = {
  async up(queryInterface) {
    // Підтягнемо потрібні КЕКВ за їх кодами (зберігаються в Kekv.name)
    const [kekv] = await queryInterface.sequelize.query(
      `SELECT id, name FROM Kekv WHERE name IN ('2210.050','2210.030','2240.010')`
    );
    const byName = Object.fromEntries(kekv.map((k) => [k.name, k.id]));
    const now = new Date();

    await queryInterface.bulkInsert("Measure", [
      {
        name: "Закупівля витратних матеріалів для ПК та оргтехніки",
        unit: "компл.",
        kekvId: byName["2210.050"],
        createdAt: now,
        updatedAt: now,
      },
      {
        name: "Придбання інструментів та інвентарю",
        unit: "шт.",
        kekvId: byName["2210.030"],
        createdAt: now,
        updatedAt: now,
      },
      {
        name: "Оплата послуг доступу до інтернету",
        unit: "послуга",
        kekvId: byName["2240.010"],
        createdAt: now,
        updatedAt: now,
      },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete("Measure", null, {});
  },
};
