"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;

    await queryInterface.createTable(
      "Measure",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
          comment: "PK",
        },
        name: {
          type: DataTypes.STRING(255),
          allowNull: false,
          comment: "Назва заходу",
        },
        unit: {
          type: DataTypes.STRING(64),
          allowNull: false,
          comment: "Одиниця виміру (шт., послуга, компл., тощо)",
        },
        kekvId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Kekv", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
          comment: "FK → Kekv(id)",
        },
        createdAt: {
          type: DataTypes.DATE,
          allowNull: false,
          defaultValue: DataTypes.NOW,
          comment: "Створено",
        },
        updatedAt: {
          type: DataTypes.DATE,
          allowNull: false,
          defaultValue: DataTypes.NOW,
          comment: "Оновлено",
        },
      },
      {
        charset: "utf8mb4",
        collate: "utf8mb4_unicode_ci",
        comment: "Заходи",
      }
    );

    await queryInterface.addIndex("Measure", ["kekvId"], {
      name: "idx_measure_kekvId",
    });
    await queryInterface.addIndex("Measure", ["name"], {
      name: "idx_measure_name",
    });

    // (опційно) захист від дублю: унікальність назви в межах одного КЕКВ
    // await queryInterface.addConstraint("Measure", {
    //   fields: ["name", "kekvId"],
    //   type: "unique",
    //   name: "ux_measure_name_kekv",
    // });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("Measure");
  },
};
