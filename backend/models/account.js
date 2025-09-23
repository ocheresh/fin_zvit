"use strict";

module.exports = (sequelize, DataTypes) => {
  const Account = sequelize.define(
    "Account",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
        comment: "PK",
      },
      accountNumber: {
        type: DataTypes.STRING(32),
        allowNull: false,
        comment: "Номер особового рахунку",
      },
      legalName: {
        type: DataTypes.STRING(255),
        allowNull: false,
        comment: "Повна юридична назва установи",
      },
      edrpou: {
        type: DataTypes.STRING(8),
        allowNull: false,
        comment: "Код ЄДРПОУ",
      },
      rozporiadNumber: {
        type: DataTypes.STRING(32),
        allowNull: true,
        comment: "Відомчий код",
      },
      additionalInfo: {
        type: DataTypes.TEXT,
        allowNull: true,
        comment: "Додаткова інформація",
      },
      subordinationId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "Підпорядкованість",
      },
    },
    {
      tableName: "Account",
      timestamps: true,
      comment: "Особові рахунки",
    }
  );

  Account.associate = (models) => {
    // належить довіднику підпорядкування
    if (models.Subordination)
      Account.belongsTo(models.Subordination, {
        foreignKey: "subordinationId",
      });

    // використовується у різних документах/реєстрах як FK
    if (models.EstimateLine)
      Account.hasMany(models.EstimateLine, { foreignKey: "accountId" });

    if (models.ProposalLine)
      Account.hasMany(models.ProposalLine, { foreignKey: "accountId" });

    if (models.BudgetExecution)
      Account.hasMany(models.BudgetExecution, { foreignKey: "accountId" });

    if (models.Request)
      Account.hasMany(models.Request, { foreignKey: "accountId" });

    if (models.RequestRegister)
      Account.hasMany(models.RequestRegister, { foreignKey: "accountId" });
  };

  return Account;
};
