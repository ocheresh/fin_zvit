"use strict";

module.exports = (sequelize, DataTypes) => {
  const Request = sequelize.define(
    "Request",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
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
        comment: "FK → Kpkv(id)",
      },
      fundId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Fund(id)",
      },

      accountId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "Хто подає (FK → Account(id))",
      },
      comment: { type: DataTypes.TEXT, allowNull: true, comment: "Примітка" },

      status: {
        type: DataTypes.STRING(16), // draft|submitted|approved|rejected
        allowNull: false,
        defaultValue: "submitted",
        comment: "Статус заявки",
      },
    },
    {
      tableName: "Request",
      timestamps: true,
      comment: "Заявка від особового на надання кошторису",
    }
  );

  Request.associate = (models) => {
    Request.belongsTo(models.Kpkv, { foreignKey: "kpkvId" });
    Request.belongsTo(models.Fund, { foreignKey: "fundId" });
    Request.belongsTo(models.Account, { foreignKey: "accountId" });
    Request.hasMany(models.RequestLine, { foreignKey: "requestId" });
  };

  return Request;
};
