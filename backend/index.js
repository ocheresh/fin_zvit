const express = require("express");

const cors = require("cors");
const app = express();

app.use(cors());

app.use(express.json());

const db = require("./models");

app.use(express.static("./app/public"));

// Підключення маршрутів
const dictRouter = require("./routes/dict");

app.use("/", dictRouter);

db.sequelize.sync().then(() => {
  app.listen(3000, () => {
    console.log("Server running on port 3000 ");
  });
});
