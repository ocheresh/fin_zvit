"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;

    await queryInterface.createTable("Estimate", {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
      },
      year: {
        type: DataTypes.INTEGER,
        allowNull: false,
        comment: "Бюджетний рік",
      },
      kpkvId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        references: { model: "Kpkv", key: "id" },
        onUpdate: "CASCADE",
        onDelete: "RESTRICT",
      },
      fundId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        references: { model: "Fund", key: "id" },
        onUpdate: "CASCADE",
        onDelete: "RESTRICT",
      },
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
    await queryInterface.dropTable("Estimate");
  },
};
