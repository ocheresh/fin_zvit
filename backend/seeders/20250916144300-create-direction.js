"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface) {
    await queryInterface.bulkInsert("Direction", [
      { name: "Централізовані заходи", info: "Міністерство оборони України" },
      { name: "Децентралізовані заходи", info: "Військові частини" },
    ]);
  },
  async down(queryInterface) {
    await queryInterface.bulkDelete("Direction", null, {});
  },
};
