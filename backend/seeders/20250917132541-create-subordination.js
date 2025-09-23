"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface) {
    await queryInterface.bulkInsert("Subordination", [
      { name: "МОУ", fullName: "Міністерство оборони України" },
      { name: "КСВ", fullName: "Командування Сухопутних військ" },
      { name: "ПС", fullName: "Повітряні сили" },
      { name: "Інше", fullName: "Інші ВЧ" },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete("Subordination", null, {});
  },
};
