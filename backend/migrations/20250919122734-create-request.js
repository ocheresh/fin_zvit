"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;

    await queryInterface.createTable(
      "Request",
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
          comment: "Номер заявки",
        },
        docDate: {
          type: DataTypes.DATEONLY,
          allowNull: false,
          comment: "Дата заявки",
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

        accountId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Account", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
          comment: "Хто подає (FK → Account(id))",
        },
        comment: { type: DataTypes.TEXT, allowNull: true, comment: "Примітка" },

        status: {
          type: DataTypes.STRING(16),
          allowNull: false,
          defaultValue: "submitted",
          comment: "draft|submitted|approved|rejected",
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
      },
      {
        charset: "utf8mb4",
        collate: "utf8mb4_unicode_ci",
        comment: "Заявка від особового",
      }
    );

    await queryInterface.addIndex("Request", ["year", "kpkvId", "fundId"], {
      name: "ix_request_year_kpkv_fund",
    });
    await queryInterface.addIndex("Request", ["number", "docDate"], {
      name: "ix_request_number_date",
    });
    await queryInterface.addIndex("Request", ["accountId"], {
      name: "ix_request_accountId",
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("Request");
  },
};
