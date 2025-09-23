// test-conn.js
require("dotenv").config();
const sequelize = require("./db");

(async () => {
  try {
    await sequelize.authenticate();
    console.log("✅ DB connected");
    process.exit(0);
  } catch (e) {
    console.error("❌ DB error:", e);
    process.exit(1);
  }
})();
