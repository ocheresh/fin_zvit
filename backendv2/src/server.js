import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import config from './config.js';
import accountsRoutes from './routes/accounts.routes.js';

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.use(config.apiPrefix + '/accounts', accountsRoutes);

app.listen(config.port, () => 
  console.log(`✅ API v2 running at http://localhost:${config.port}${config.apiPrefix}`)
);
