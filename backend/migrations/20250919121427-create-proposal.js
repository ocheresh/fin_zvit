"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;

    await queryInterface.createTable(
      "Proposal",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
          comment: "PK",
        },
        number: {
          type: DataTypes.STRING(32),
          allowNull: false,
          comment: "Номер пропозицій",
        },
        docDate: {
          type: DataTypes.DATEONLY,
          allowNull: false,
          comment: "Дата пропозицій",
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
          comment: "FK → Kpkv(id)",
        },
        fundId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Fund", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
          comment: "FK → Fund(id)",
        },

        estimateId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: true,
          references: { model: "Estimate", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "SET NULL",
          comment: "Опційно: базовий кошторис",
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
        comment: "Пропозиції (зміни до кошторису)",
      }
    );

    await queryInterface.addIndex("Proposal", ["year", "kpkvId", "fundId"], {
      name: "ix_proposal_year_kpkv_fund",
    });
    await queryInterface.addIndex("Proposal", ["number", "docDate"], {
      name: "ix_proposal_number_date",
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("Proposal");
  },
};
