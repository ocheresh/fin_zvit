require('dotenv').config();

module.exports = {
  development: {
    url: process.env.DATABASE_URL,
    dialect: 'mysql',
    logging: false,
    // Якщо PlanetScale / інший хост із TLS, розкоментуй:
    // dialectOptions: { ssl: { rejectUnauthorized: true } },
  }
};
