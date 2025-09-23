"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;

    await queryInterface.createTable(
      "ProposalLine",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
          comment: "PK",
        },

        proposalId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Proposal", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "CASCADE",
          comment: "FK → Proposal(id)",
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

        amount: {
          type: DataTypes.DECIMAL(15, 2),
          allowNull: false,
          comment: "Сума (зміни)",
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
        comment: "Рядки пропозицій (зміни до кошторису)",
      }
    );

    await queryInterface.addIndex("ProposalLine", ["proposalId"], {
      name: "ix_proposalline_proposalId",
    });
    await queryInterface.addIndex("ProposalLine", ["kekvId"], {
      name: "ix_proposalline_kekvId",
    });
    await queryInterface.addIndex("ProposalLine", ["accountId"], {
      name: "ix_proposalline_accountId",
    });
    await queryInterface.addIndex("ProposalLine", ["measureId"], {
      name: "ix_proposalline_measureId",
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("ProposalLine");
  },
};
