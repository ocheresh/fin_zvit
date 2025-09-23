"use strict";

module.exports = (sequelize, DataTypes) => {
  const Measure = sequelize.define(
    "Measure",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
      },
      name: { type: DataTypes.STRING(255), allowNull: false }, // Назва заходу
      unit: { type: DataTypes.STRING(64), allowNull: false }, // Одиниця виміру (шт., послуга, тощо)
      kekvId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false }, // FK → Kekv(id)
    },
    { tableName: "Measure", timestamps: true, comment: "Заходи" }
  );

  Measure.associate = (models) => {
    Measure.belongsTo(models.Kekv, { foreignKey: "kekvId" });
  };

  return Measure;
};
