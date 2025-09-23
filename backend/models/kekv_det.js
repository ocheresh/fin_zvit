"use strict";
module.exports = (sequelize, DataTypes) => {
  const KekvDet = sequelize.define(
    "KekvDet",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
      },
      name: { type: DataTypes.STRING, allowNull: false }, // код KEKV, напр. 2210.050
      info: { type: DataTypes.TEXT, allowNull: true },
      kekvId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    },
    {
      tableName: "KekvDet",
      Comment: "KEKV_det",
      timestamps: false,
    }
  );
  KekvDet.associate = (models) => {
    KekvDet.belongsTo(models.Kekv, { foreignKey: "kekvId" });
  };

  // Якщо захочеш зв’язок: KekvDet.belongsTo(Kekv, { foreignKey: 'name', targetKey: 'name' })
  return KekvDet;
};
