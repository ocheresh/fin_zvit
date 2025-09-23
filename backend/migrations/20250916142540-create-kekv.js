"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;
    await queryInterface.createTable(
      "Kekv",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
        },
        name: { type: DataTypes.STRING(32), allowNull: false, unique: true }, // 2210.050
        info: { type: DataTypes.TEXT, allowNull: true },
      },
      { charset: "utf8mb4", collate: "utf8mb4_unicode_ci" }
    );
    // await queryInterface.addIndex("Kekv", ["name"], { name: "idx_kekv_code" });
  },
  async down(queryInterface) {
    await queryInterface.dropTable("Kekv");
  },
};
