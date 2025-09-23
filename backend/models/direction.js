"use strict";
module.exports = (sequelize, DataTypes) => {
  const Direction = sequelize.define(
    "Direction",
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
      tableName: "Direction",
      Comment: "Напрямок",
      timestamps: false,
    }
  );
  return Direction;
};
