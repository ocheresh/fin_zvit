"use strict";

module.exports = (sequelize, DataTypes) => {
  const Proposal = sequelize.define(
    "Proposal",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
      },
      number: {
        type: DataTypes.STRING(32),
        allowNull: false,
        comment: "Номер пропозицій",
      },
      docDate: {
        type: DataTypes.DATEONLY,
        allowNull: false,
        comment: "Дата пропозицій",
      },

      year: {
        type: DataTypes.INTEGER,
        allowNull: false,
        comment: "Бюджетний рік",
      },
      kpkvId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Kpkv(id)",
      },
      fundId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Fund(id)",
      },

      // опційно: прив'язка до базового кошторису
      estimateId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: true,
        comment: "FK → Estimate(id)",
      },
    },
    {
      tableName: "Proposal",
      timestamps: true,
      comment: "Пропозиції (зміни до кошторису)",
    }
  );

  Proposal.associate = (models) => {
    Proposal.belongsTo(models.Kpkv, { foreignKey: "kpkvId" });
    Proposal.belongsTo(models.Fund, { foreignKey: "fundId" });
    Proposal.belongsTo(models.Estimate, { foreignKey: "estimateId" }); // не обов'язково
    Proposal.hasMany(models.ProposalLine, { foreignKey: "proposalId" });
  };

  return Proposal;
};
