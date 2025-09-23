"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;
    await queryInterface.createTable(
      "KekvDet",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
        },
        kekvId: {
          // FK → Kekv(id)
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Kekv", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
        },
        info: { type: DataTypes.TEXT, allowNull: true }, // "Варіант 1/2/3"
      },
      { charset: "utf8mb4", collate: "utf8mb4_unicode_ci" }
    );

    await queryInterface.addIndex("KekvDet", ["kekvId"], {
      name: "idx_kekvdet_kekvId",
    });
  },
  async down(queryInterface) {
    await queryInterface.dropTable("KekvDet");
  },
};
