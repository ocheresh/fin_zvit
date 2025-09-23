"use strict";

module.exports = {
  async up(queryInterface) {
    // Отримуємо id підпорядкувань
    const [subs] = await queryInterface.sequelize.query(
      `SELECT id, name FROM Subordination WHERE name IN ('МОУ','КСВ','ПС','Інше')`
    );
    const subId = Object.fromEntries(subs.map((s) => [s.name, s.id]));

    // Дати з прикладу можна зберегти; якщо не критично — ставимо now
    const now = new Date();

    await queryInterface.bulkInsert("Account", [
      {
        accountNumber: "50001",
        legalName: "Міністерство оборони України",
        edrpou: "24900000",
        rozporiadNumber: "18611",
        additionalInfo: "",
        subordinationId: subId["МОУ"],
        createdAt: new Date("2025-09-05T10:58:26.398Z"),
        updatedAt: new Date("2025-09-05T11:30:24.749Z"),
      },
      {
        accountNumber: "53001",
        legalName: "Командування СВ ЗСУ (в/ч А0105)",
        edrpou: "22991037",
        rozporiadNumber: "16140",
        additionalInfo: "",
        subordinationId: subId["КСВ"],
        createdAt: now,
        updatedAt: now,
      },
      {
        accountNumber: "50348",
        legalName:
          "Центральний науково-дослідний інститут Збройних Сил України",
        edrpou: "00000000",
        rozporiadNumber: "15983",
        additionalInfo: "",
        subordinationId: subId["Інше"],
        createdAt: now,
        updatedAt: now,
      },
      {
        accountNumber: "50105",
        legalName: "Військова частина А2791",
        edrpou: "00000000",
        rozporiadNumber: "03947",
        additionalInfo: "",
        subordinationId: subId["Інше"],
        createdAt: now,
        updatedAt: now,
      },
      {
        accountNumber: "56001",
        legalName: "Командування ПС ЗСУ (в/ч А0215)",
        edrpou: "00000000",
        rozporiadNumber: "02003",
        additionalInfo: "",
        subordinationId: subId["ПС"],
        createdAt: now,
        updatedAt: now,
      },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete("Account", null, {});
  },
};
