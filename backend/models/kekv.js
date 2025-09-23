"use strict";
module.exports = (sequelize, DataTypes) => {
  const Kekv = sequelize.define(
    "Kekv",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
      },
      name: { type: DataTypes.STRING(32), allowNull: false, unique: true },
      info: { type: DataTypes.TEXT, allowNull: true },
    },
    {
      tableName: "Kekv",
      Comment: "КЕКВ",
      timestamps: false,
    }
  );
  Kekv.associate = (models) => {
    Kekv.hasMany(models.Measure, { foreignKey: "kekvId" });
    Kekv.hasMany(models.KekvDet, { foreignKey: "kekvId" }); // якщо у KekvDet є поле kekvId
    Kekv.hasMany(models.EstimateLine, { foreignKey: "kekvId" });
    Kekv.hasMany(models.ProposalLine, { foreignKey: "kekvId" });
    Kekv.hasMany(models.BudgetExecution, { foreignKey: "kekvId" });
    Kekv.hasMany(models.RequestLine, { foreignKey: "kekvId" });
    Kekv.hasMany(models.RequestRegister, { foreignKey: "kekvId" });
  };

  // Якщо захочеш зв’язок: KekvDet.belongsTo(Kekv, { foreignKey: 'name', targetKey: 'name' })
  return Kekv;
};
