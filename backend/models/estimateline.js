"use strict";

module.exports = (sequelize, DataTypes) => {
  const EstimateLine = sequelize.define(
    "EstimateLine",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
      },
      estimateId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
      kekvId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
      accountId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
      measureId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
      amount: { type: DataTypes.DECIMAL(15, 2), allowNull: false },
    },
    { tableName: "EstimateLine", timestamps: true, comment: "Рядки кошторису" }
  );

  EstimateLine.associate = (models) => {
    EstimateLine.belongsTo(models.Estimate, { foreignKey: "estimateId" });
    EstimateLine.belongsTo(models.Kekv, { foreignKey: "kekvId" });
    EstimateLine.belongsTo(models.Account, { foreignKey: "accountId" });
    EstimateLine.belongsTo(models.Measure, { foreignKey: "measureId" });
  };

  return EstimateLine;
};
