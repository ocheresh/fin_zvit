"use strict";

module.exports = (sequelize, DataTypes) => {
  const ProposalLine = sequelize.define(
    "ProposalLine",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
      },
      proposalId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Proposal(id)",
      },

      kekvId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Kekv(id)",
      },
      accountId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Account(id)",
      },
      measureId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Measure(id)",
      },

      amount: {
        type: DataTypes.DECIMAL(15, 2),
        allowNull: false,
        comment: "Сума (зміни)",
      },
    },
    {
      tableName: "ProposalLine",
      timestamps: true,
      comment: "Рядки пропозицій (зміни до кошторису)",
    }
  );

  ProposalLine.associate = (models) => {
    ProposalLine.belongsTo(models.Proposal, { foreignKey: "proposalId" });
    ProposalLine.belongsTo(models.Kekv, { foreignKey: "kekvId" });
    ProposalLine.belongsTo(models.Account, { foreignKey: "accountId" });
    ProposalLine.belongsTo(models.Measure, { foreignKey: "measureId" });
  };

  return ProposalLine;
};
