const express = require("express");
const sql = require("mssql");

const app = express();
app.use(express.json());

const dbConfig = {
  server: process.env.SQL_SERVER_FQDN,
  database: process.env.SQL_DATABASE_NAME,
  options: {
    encrypt: true
  },
  authentication: {
    type: "azure-active-directory-msi-app-service"
  }
};

app.get("/", (req, res) => {
  res.send("Smart Notes connected to Azure SQL Database");
});

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/notes", async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request().query("SELECT * FROM Notes");
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
