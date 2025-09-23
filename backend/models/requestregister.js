"use strict";

module.exports = (sequelize, DataTypes) => {
  const RequestRegister = sequelize.define(
    "RequestRegister",
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        primaryKey: true,
        autoIncrement: true,
      },

      // контекст
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
      accountId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Account(id)",
      },

      // деталізація
      kekvId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Kekv(id)",
      },
      measureId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "FK → Measure(id)",
      },
      amount: {
        type: DataTypes.DECIMAL(15, 2),
        allowNull: false,
        comment: "Запитувана сума",
      },

      // джерело та життєвий цикл
      requestId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "Походження: Request(id)",
      },
      requestLineId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "Походження: RequestLine(id)",
      },

      stage: {
        type: DataTypes.STRING(16), // pending|accepted|rejected|processed
        allowNull: false,
        defaultValue: "pending",
        comment: "Стан обробки у реєстрі",
      },

      // зв’язок із створеними пропозиціями (коли оброблено)
      proposalId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: true,
        comment: "Створена Proposal(id)",
      },
      proposalLineId: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: true,
        comment: "Створена ProposalLine(id)",
      },
    },
    {
      tableName: "RequestRegister",
      timestamps: true,
      comment: "Проміжний реєстр заявок для формування Пропозицій",
    }
  );

  RequestRegister.associate = (models) => {
    RequestRegister.belongsTo(models.Kpkv, { foreignKey: "kpkvId" });
    RequestRegister.belongsTo(models.Fund, { foreignKey: "fundId" });
    RequestRegister.belongsTo(models.Account, { foreignKey: "accountId" });
    RequestRegister.belongsTo(models.Kekv, { foreignKey: "kekvId" });
    RequestRegister.belongsTo(models.Measure, { foreignKey: "measureId" });

    RequestRegister.belongsTo(models.Request, { foreignKey: "requestId" });
    RequestRegister.belongsTo(models.RequestLine, {
      foreignKey: "requestLineId",
    });

    RequestRegister.belongsTo(models.Proposal, { foreignKey: "proposalId" });
    RequestRegister.belongsTo(models.ProposalLine, {
      foreignKey: "proposalLineId",
    });
  };

  return RequestRegister;
};
