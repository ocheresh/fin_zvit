"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;
    await queryInterface.createTable(
      "Account",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
          comment: "PK",
        },
        accountNumber: {
          type: DataTypes.STRING(32),
          allowNull: false,
          comment: "Номер особового рахунку",
        },
        legalName: {
          type: DataTypes.STRING(255),
          allowNull: false,
          comment: "Повна юридична назва установи",
        },
        edrpou: {
          type: DataTypes.STRING(16),
          allowNull: false,
          comment: "Код ЄДРПОУ",
        },
        rozporiadNumber: {
          type: DataTypes.STRING(32),
          allowNull: true,
          comment: "Відомчий код",
        },
        additionalInfo: {
          type: DataTypes.TEXT,
          allowNull: true,
          comment: "Додаткова інформація (примітки)",
        },
        subordinationId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Subordination", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
          comment: "FK → Subordination(id)",
        },
        createdAt: {
          type: DataTypes.DATE,
          allowNull: false,
          defaultValue: DataTypes.NOW,
          comment: "Коли створено запис",
        },
        updatedAt: {
          type: DataTypes.DATE,
          allowNull: false,
          defaultValue: DataTypes.NOW,
          comment: "Останнє оновлення запису",
        },
      },
      {
        charset: "utf8mb4",
        collate: "utf8mb4_unicode_ci",
        comment: "Особові рахунки",
      }
    );

    await queryInterface.addIndex("Account", ["accountNumber"], {
      name: "idx_account_accountNumber",
    });
    await queryInterface.addIndex("Account", ["edrpou"], {
      name: "idx_account_edrpou",
    });
    await queryInterface.addIndex("Account", ["subordinationId"], {
      name: "idx_account_subordinationId",
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("Account");
  },
};
