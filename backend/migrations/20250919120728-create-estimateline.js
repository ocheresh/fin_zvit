"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;

    await queryInterface.createTable("EstimateLine", {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
      },
      estimateId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        references: { model: "Estimate", key: "id" },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      kekvId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        references: { model: "Kekv", key: "id" },
        onUpdate: "CASCADE",
        onDelete: "RESTRICT",
      },
      accountId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        references: { model: "Account", key: "id" },
        onUpdate: "CASCADE",
        onDelete: "RESTRICT",
      },
      measureId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        references: { model: "Measure", key: "id" },
        onUpdate: "CASCADE",
        onDelete: "RESTRICT",
      },
      amount: { type: DataTypes.DECIMAL(15, 2), allowNull: false },
      createdAt: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
      updatedAt: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("EstimateLine");
  },
};
