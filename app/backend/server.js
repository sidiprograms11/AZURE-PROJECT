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
  res.send(`
<!DOCTYPE html>
<html>
<head>
  <title>Smart Notes</title>
</head>
<body>
  <h1>Smart Notes</h1>
  <p>Application sécurisée sur Azure App Service, Azure SQL et Key Vault.</p>

  <h2>Ajouter une note</h2>
  <input id="title" placeholder="Titre">
  <br><br>
  <textarea id="content" placeholder="Contenu"></textarea>
  <br><br>
  <button onclick="addNote()">Ajouter</button>

  <h2>Notes</h2>
  <div id="notes"></div>

  <script>
    async function loadNotes() {
      const res = await fetch('/notes');
      const notes = await res.json();

      document.getElementById('notes').innerHTML = notes.map(note => \`
        <div style="border:1px solid #ccc; padding:10px; margin:10px;">
          <h3>\${note.Title}</h3>
          <p>\${note.Content}</p>
          <button onclick="deleteNote(\${note.Id})">Supprimer</button>
        </div>
      \`).join('');
    }

    async function addNote() {
      const title = document.getElementById('title').value;
      const content = document.getElementById('content').value;

      await fetch('/notes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, content })
      });

      document.getElementById('title').value = '';
      document.getElementById('content').value = '';
      loadNotes();
    }

    async function deleteNote(id) {
      await fetch('/notes/' + id, {
        method: 'DELETE'
      });

      loadNotes();
    }

    loadNotes();
  </script>
</body>
</html>
  `);
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
