"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;
    await queryInterface.createTable(
      "Subordination",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          comment: "PK",
        },
        name: {
          type: DataTypes.STRING(64),
          allowNull: false,
          unique: true,
          comment: "Скорочена назва підпорядкування (напр. МОУ, КСВ, ПС, Інше)",
        },
        fullName: {
          type: DataTypes.STRING(255),
          allowNull: false,
          unique: true,
          comment: "Повна назва",
        },
      },
      { charset: "utf8mb4", collate: "utf8mb4_unicode_ci" }
    );
  },

  async down(queryInterface) {
    await queryInterface.dropTable("Subordination");
  },
};
