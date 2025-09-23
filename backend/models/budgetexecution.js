"use strict";

module.exports = (sequelize, DataTypes) => {
  const BudgetExecution = sequelize.define(
    "BudgetExecution",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
      },

      opDate: {
        type: DataTypes.DATEONLY,
        allowNull: false,
        comment: "Дата операції",
      },
      docNo: {
        type: DataTypes.STRING(64),
        allowNull: true,
        comment: "Номер первинного документа",
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

      stage: {
        type: DataTypes.STRING(16), // 'obligation' | 'cash'
        allowNull: false,
        comment: "Етап: obligation (зобов'яз.), cash (касові)",
      },

      amount: {
        type: DataTypes.DECIMAL(15, 2),
        allowNull: false,
        comment: "Сума операції",
      },
      comment: { type: DataTypes.TEXT, allowNull: true, comment: "Примітка" },

      estimateId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: true,
        comment: "Опц. FK → Estimate(id)",
      },
      estimateLineId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: true,
        comment: "Опц. FK → EstimateLine(id)",
      },
      proposalId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: true,
        comment: "Опц. FK → Proposal(id)",
      },
      proposalLineId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: true,
        comment: "Опц. FK → ProposalLine(id)",
      },
    },
    {
      tableName: "BudgetExecution",
      timestamps: true,
      comment: "Реєстр виконання кошторису",
    }
  );

  BudgetExecution.associate = (models) => {
    BudgetExecution.belongsTo(models.Kpkv, { foreignKey: "kpkvId" });
    BudgetExecution.belongsTo(models.Fund, { foreignKey: "fundId" });
    BudgetExecution.belongsTo(models.Kekv, { foreignKey: "kekvId" });
    BudgetExecution.belongsTo(models.Account, { foreignKey: "accountId" });
    BudgetExecution.belongsTo(models.Measure, { foreignKey: "measureId" });

    BudgetExecution.belongsTo(models.Estimate, { foreignKey: "estimateId" });
    BudgetExecution.belongsTo(models.EstimateLine, {
      foreignKey: "estimateLineId",
    });
    BudgetExecution.belongsTo(models.Proposal, { foreignKey: "proposalId" });
    BudgetExecution.belongsTo(models.ProposalLine, {
      foreignKey: "proposalLineId",
    });
  };

  return BudgetExecution;
};
