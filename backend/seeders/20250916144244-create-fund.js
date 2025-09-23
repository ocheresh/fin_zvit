"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface) {
    await queryInterface.bulkInsert("Fund", [
      { name: "Загальний", info: "" },
      { name: "Спеціальний", info: "" },
    ]);
  },
  async down(queryInterface) {
    await queryInterface.bulkDelete("Fund", null, {});
  },
};
