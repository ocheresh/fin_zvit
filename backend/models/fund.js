"use strict";
module.exports = (sequelize, DataTypes) => {
  const Fund = sequelize.define(
    "Fund",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
      },
      name: { type: DataTypes.STRING, allowNull: false },
      info: { type: DataTypes.TEXT, allowNull: true },
    },
    {
      tableName: "Fund",
      comment: "Фонд",
      timestamps: false,
    }
  );

  // 🔗 Асоціації
  Fund.associate = (models) => {
    // Документи (шапки)
    if (models.Estimate)
      Fund.hasMany(models.Estimate, { foreignKey: "fundId" });

    if (models.Proposal)
      Fund.hasMany(models.Proposal, { foreignKey: "fundId" });

    if (models.Request) Fund.hasMany(models.Request, { foreignKey: "fundId" });

    // Реєстри/операції
    if (models.BudgetExecution)
      Fund.hasMany(models.BudgetExecution, { foreignKey: "fundId" });

    if (models.RequestRegister)
      Fund.hasMany(models.RequestRegister, { foreignKey: "fundId" });
  };

  return Fund;
};
