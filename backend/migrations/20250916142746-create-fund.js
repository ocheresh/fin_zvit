"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;
    await queryInterface.createTable(
      "Fund",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
        },
        name: { type: DataTypes.STRING(255), allowNull: false },
        info: { type: DataTypes.TEXT, allowNull: true },
      },
      { charset: "utf8mb4", collate: "utf8mb4_unicode_ci" }
    );
    await queryInterface.addIndex("Fund", ["name"], { name: "idx_fund_name" });
  },
  async down(queryInterface) {
    await queryInterface.dropTable("Fund");
  },
};
