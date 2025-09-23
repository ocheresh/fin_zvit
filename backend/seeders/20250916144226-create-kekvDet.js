"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface) {
    // дістанемо id потрібних KEKV за їх name
    const [rows] = await queryInterface.sequelize.query(
      `SELECT id, name FROM Kekv WHERE name IN ('2210.050','2210.030')`
    );
    const byName = Object.fromEntries(rows.map((r) => [r.name, r.id]));

    await queryInterface.bulkInsert("KekvDet", [
      { kekvId: byName["2210.050"], info: "Варіант 1" },
      { kekvId: byName["2210.050"], info: "Варіант 2" },
      { kekvId: byName["2210.030"], info: "Варіант 3" },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete("KekvDet", null, {});
  },
};
