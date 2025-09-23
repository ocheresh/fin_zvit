"use strict";

module.exports = (sequelize, DataTypes) => {
  const RequestLine = sequelize.define(
    "RequestLine",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
      },
      requestId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Request(id)",
      },

      kekvId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Kekv(id)",
      },
      measureId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
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
        comment: "Коротка примітка",
      },
    },
    { tableName: "RequestLine", timestamps: true, comment: "Рядки заявки" }
  );

  RequestLine.associate = (models) => {
    RequestLine.belongsTo(models.Request, { foreignKey: "requestId" });
    RequestLine.belongsTo(models.Kekv, { foreignKey: "kekvId" });
    RequestLine.belongsTo(models.Measure, { foreignKey: "measureId" });
  };

  return RequestLine;
};
