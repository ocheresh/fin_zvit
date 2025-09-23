"use strict";

module.exports = (sequelize, DataTypes) => {
  const Subordination = sequelize.define(
    "Subordination",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
        comment: "PK",
      },
      name: {
        type: DataTypes.STRING(64),
        allowNull: false,
        unique: true,
        comment: "Скорочена назва підпорядкування (напр. МОУ, КСВ, ПС, Інше)",
      },
      fullName: {
        type: DataTypes.STRING(255),
        allowNull: false,
        unique: true,
        comment: "Повна назва",
      },
    },
    { tableName: "Subordination", timestamps: false }
  );

  Subordination.associate = (models) => {
    Subordination.hasMany(models.Account, { foreignKey: "subordinationId" });
  };

  return Subordination;
};
