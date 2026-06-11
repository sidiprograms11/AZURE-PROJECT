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
    res.status(500).json({ error: err.message });
  }
});

app.post("/notes", async (req, res) => {
  try {
    const { title, content } = req.body;

    const pool = await sql.connect(dbConfig);

    await pool.request()
      .input("title", sql.NVarChar(200), title)
      .input("content", sql.NVarChar(sql.MAX), content)
      .query(`
        INSERT INTO Notes (Title, Content)
        VALUES (@title, @content)
      `);

    res.status(201).json({
      message: "Note created successfully"
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put("/notes/:id", async (req, res) => {
  try {
    const { title, content } = req.body;
    const id = req.params.id;

    const pool = await sql.connect(dbConfig);

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

    res.json({
      message: "Note updated successfully"
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete("/notes/:id", async (req, res) => {
  try {
    const id = req.params.id;

    const pool = await sql.connect(dbConfig);

    await pool.request()
      .input("id", sql.Int, id)
      .query(`
        DELETE FROM Notes
        WHERE Id = @id
      `);

    res.json({
      message: "Note deleted successfully"
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
