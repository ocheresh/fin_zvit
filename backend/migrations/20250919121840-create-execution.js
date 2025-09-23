"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;

    await queryInterface.createTable(
      "BudgetExecution",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
          comment: "PK",
        },

        opDate: {
          type: DataTypes.DATEONLY,
          allowNull: false,
          comment: "Дата операції",
        },
        docNo: {
          type: DataTypes.STRING(64),
          allowNull: true,
          comment: "Номер первинного документа",
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

        kekvId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Kekv", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
          comment: "FK → Kekv(id)",
        },
        accountId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Account", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
          comment: "FK → Account(id)",
        },
        measureId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Measure", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
          comment: "FK → Measure(id)",
        },

        stage: {
          type: DataTypes.STRING(16),
          allowNull: false,
          comment: "Етап: obligation (зобов'язання) або cash (касові)",
        },

        amount: {
          type: DataTypes.DECIMAL(15, 2),
          allowNull: false,
          comment: "Сума операції",
        },
        comment: { type: DataTypes.TEXT, allowNull: true, comment: "Примітка" },

        estimateId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: true,
          references: { model: "Estimate", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "SET NULL",
          comment: "Опціонально: прив'язка до кошторису",
        },
        estimateLineId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: true,
          references: { model: "EstimateLine", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "SET NULL",
          comment: "Опціонально: рядок кошторису",
        },
        proposalId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: true,
          references: { model: "Proposal", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "SET NULL",
          comment: "Опціонально: документ Пропозиції",
        },
        proposalLineId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: true,
          references: { model: "ProposalLine", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "SET NULL",
          comment: "Опціонально: рядок Пропозицій",
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
        comment: "Реєстр виконання кошторису",
      }
    );

    // Корисні індекси для звітів
    await queryInterface.addIndex(
      "BudgetExecution",
      ["year", "kpkvId", "fundId"],
      { name: "ix_exec_year_kpkv_fund" }
    );
    await queryInterface.addIndex("BudgetExecution", ["opDate"], {
      name: "ix_exec_opDate",
    });
    await queryInterface.addIndex("BudgetExecution", ["kekvId"], {
      name: "ix_exec_kekvId",
    });
    await queryInterface.addIndex("BudgetExecution", ["accountId"], {
      name: "ix_exec_accountId",
    });
    await queryInterface.addIndex("BudgetExecution", ["measureId"], {
      name: "ix_exec_measureId",
    });
    await queryInterface.addIndex("BudgetExecution", ["stage"], {
      name: "ix_exec_stage",
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("BudgetExecution");
  },
};
