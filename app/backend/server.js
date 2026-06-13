const express = require("express");
const sql = require("mssql");
const { DefaultAzureCredential } = require("@azure/identity");
const { SecretClient } = require("@azure/keyvault-secrets");

const app = express();
app.use(express.json());

let dbConfig = null;

async function loadDbConfig() {
  if (dbConfig) return dbConfig;

  const credential = new DefaultAzureCredential();
  const client = new SecretClient(process.env.KEY_VAULT_URL, credential);

  const sqlServer = await client.getSecret("sql-server-fqdn");
  const sqlDatabase = await client.getSecret("sql-database-name");

  dbConfig = {
    server: sqlServer.value,
    database: sqlDatabase.value,
    options: {
      encrypt: true
    },
    authentication: {
      type: "azure-active-directory-msi-app-service"
    }
  };

  return dbConfig;
}

async function getPool() {
  const config = await loadDbConfig();
  return await sql.connect(config);
}

app.get("/", (req, res) => {
  res.send("Smart Notes connected to Azure SQL Database through Azure Key Vault");
});

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/notes", async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query("SELECT * FROM Notes");
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/notes", async (req, res) => {
  try {
    const { title, content } = req.body;

    const pool = await getPool();

    await pool.request()
      .input("title", sql.NVarChar(200), title)
      .input("content", sql.NVarChar(sql.MAX), content)
      .query(`
        INSERT INTO Notes (Title, Content)
        VALUES (@title, @content)
      `);

    res.status(201).json({ message: "Note created successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put("/notes/:id", async (req, res) => {
  try {
    const { title, content } = req.body;
    const id = req.params.id;

    const pool = await getPool();

    await pool.request()
      .input("id", sql.Int, id)
      .input("title", sql.NVarChar(200), title)
      .input("content", sql.NVarChar(sql.MAX), content)
      .query(`
        UPDATE Notes
        SET Title = @title,
            Content = @content
        WHERE Id = @id
      `);

    res.json({ message: "Note updated successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete("/notes/:id", async (req, res) => {
  try {
    const id = req.params.id;

    const pool = await getPool();

    await pool.request()
      .input("id", sql.Int, id)
      .query(`
        DELETE FROM Notes
        WHERE Id = @id
      `);

    res.json({ message: "Note deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
