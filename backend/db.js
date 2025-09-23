// db.js
const { Sequelize } = require("sequelize");

const url = process.env.DATABASE_URL;

const sequelize = url
  ? new Sequelize(url, {
      dialect: "mysql",

      logging: false,
    })
  : new Sequelize(
      process.env.DB_NAME,
      process.env.DB_USER,
      process.env.DB_PASS,
      {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT || 3306,
        dialect: "mysql",
        dialectOptions: {
          ssl: { rejectUnauthorized: true }, // лиши true для PlanetScale
        },
        logging: false,
      }
    );

module.exports = sequelize;
