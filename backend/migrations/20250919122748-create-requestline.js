"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const { DataTypes } = Sequelize;

    await queryInterface.createTable(
      "RequestLine",
      {
        id: {
          type: DataTypes.INTEGER.UNSIGNED,
          primaryKey: true,
          autoIncrement: true,
          allowNull: false,
          comment: "PK",
        },
        requestId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Request", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "CASCADE",
          comment: "FK → Request(id)",
        },

        kekvId: {
          type: DataTypes.INTEGER.UNSIGNED,
          allowNull: false,
          references: { model: "Kekv", key: "id" },
          onUpdate: "CASCADE",
          onDelete: "RESTRICT",
          comment: "FK → Kekv(id)",
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
          comment: "Сума",
        },
        note: {
          type: DataTypes.STRING(255),
          allowNull: true,
          comment: "Примітка",
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
        comment: "Рядки заявки",
      }
    );

    await queryInterface.addIndex("RequestLine", ["requestId"], {
      name: "ix_requestline_requestId",
    });
    await queryInterface.addIndex("RequestLine", ["kekvId"], {
      name: "ix_requestline_kekvId",
    });
    await queryInterface.addIndex("RequestLine", ["measureId"], {
      name: "ix_requestline_measureId",
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable("RequestLine");
  },
};
