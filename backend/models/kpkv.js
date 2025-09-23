"use strict";
module.exports = (sequelize, DataTypes) => {
  const Kpkv = sequelize.define(
    "Kpkv",
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
      tableName: "Kpkv",
      comment: "КПКВ",
      timestamps: false,
    }
  );

  // 🔗 Асоціації
  Kpkv.associate = (models) => {
    // документи (шапки)
    if (models.Estimate)
      Kpkv.hasMany(models.Estimate, { foreignKey: "kpkvId" });

    if (models.Proposal)
      Kpkv.hasMany(models.Proposal, { foreignKey: "kpkvId" });

    if (models.Request) Kpkv.hasMany(models.Request, { foreignKey: "kpkvId" });

    // реєстри/рядки
    if (models.BudgetExecution)
      Kpkv.hasMany(models.BudgetExecution, { foreignKey: "kpkvId" });

    if (models.RequestRegister)
      Kpkv.hasMany(models.RequestRegister, { foreignKey: "kpkvId" });

    // (рядкові частини кошторису/пропозицій не містять kpkvId напряму — вони йдуть через шапку)
  };

  return Kpkv;
};
