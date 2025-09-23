"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;

    await queryInterface.createTable(
      "RequestRegister",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
          comment: "PK",
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
        accountId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Account", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
        },

        kekvId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Kekv", key: "id" },
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

        amount: {
          type: DataTypes.DECIMAL(15, 2),
          allowNull: false,
          comment: "Запитувана сума",
        },

        requestId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Request", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "CASCADE",
        },
        requestLineId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "RequestLine", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "CASCADE",
        },

        stage: {
          type: DataTypes.STRING(16),
          allowNull: false,
          defaultValue: "pending",
          comment: "pending|accepted|rejected|processed",
        },

        proposalId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: true,
          references: { model: "Proposal", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "SET NULL",
        },
        proposalLineId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: true,
          references: { model: "ProposalLine", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "SET NULL",
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
        comment: "Проміжний реєстр заявок",
      }
    );

    await queryInterface.addIndex(
      "RequestRegister",
      ["year", "kpkvId", "fundId"],
      { name: "ix_reqreg_year_kpkv_fund" }
    );
    await queryInterface.addIndex("RequestRegister", ["accountId"], {
      name: "ix_reqreg_accountId",
    });
    await queryInterface.addIndex("RequestRegister", ["kekvId"], {
      name: "ix_reqreg_kekvId",
    });
    await queryInterface.addIndex("RequestRegister", ["measureId"], {
      name: "ix_reqreg_measureId",
    });
    await queryInterface.addIndex("RequestRegister", ["stage"], {
      name: "ix_reqreg_stage",
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("RequestRegister");
  },
};
