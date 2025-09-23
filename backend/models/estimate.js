"use strict";

module.exports = (sequelize, DataTypes) => {
  const Estimate = sequelize.define(
    "Estimate",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
      },
      year: {
        type: DataTypes.INTEGER,
        allowNull: false,
        comment: "Бюджетний рік",
      },
      kpkvId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
      fundId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    },
    { tableName: "Estimate", timestamps: true, comment: "Кошторис" }
  );

  Estimate.associate = (models) => {
    Estimate.belongsTo(models.Kpkv, { foreignKey: "kpkvId" });
    Estimate.belongsTo(models.Fund, { foreignKey: "fundId" });
    Estimate.hasMany(models.EstimateLine, { foreignKey: "estimateId" });
  };

  return Estimate;
};
