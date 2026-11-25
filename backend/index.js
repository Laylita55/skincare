const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const dbConfig = {
  host: '127.0.0.1',
  user: 'tienda_user',
  password: '123456',
  database: 'test'
};

app.post('/api/compras', async (req, res) => {
  try {
    const { cliente, producto, cantidad, total } = req.body;
    if (!cliente || !producto || !total) {
      return res.status(400).json({ error: 'Faltan datos obligatorios' });
    }

    const conn = await mysql.createConnection(dbConfig);
    const [result] = await conn.execute(
      'INSERT INTO compras (cliente, producto, cantidad, total) VALUES (?, ?, ?, ?)',
      [cliente, producto, Number(cantidad) || 1, Number(total)]
    );
    await conn.end();

    res.status(201).json({ ok: true, id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al guardar la compra' });
  }
});

app.get('/api/compras', async (req, res) => {
  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.execute('SELECT * FROM compras ORDER BY id DESC');
    await conn.end();
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al consultar compras' });
  }
});

app.get('/compras', async (req, res) => {
  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.execute('SELECT * FROM compras ORDER BY id DESC');
    await conn.end();

    const filasHtml = rows.map(c => `
      <tr>
        <td>${c.id}</td>
        <td>${c.cliente}</td>
        <td>${c.producto}</td>
        <td>${c.cantidad}</td>
        <td>$${Number(c.total).toFixed(2)}</td>
        <td>${new Date(c.creado_en).toLocaleString()}</td>
      </tr>
    `).join('');

    res.send(`
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Panel de Compras</title>
        <style>
          body { font-family: sans-serif; padding: 20px; background: #111; color: #eee; }
          table { width: 100%; border-collapse: collapse; margin-top: 16px; }
          th, td { border: 1px solid #333; padding: 8px; text-align: left; }
          th { background: #222; }
        </style>
      </head>
      <body>
        <h1>Compras registradas</h1>
        <table>
          <thead>
            <tr>
              <th>ID</th><th>Cliente</th><th>Producto</th><th>Cant.</th><th>Total</th><th>Fecha</th>
            </tr>
          </thead>
          <tbody>
            ${filasHtml || '<tr><td colspan="6">Sin compras aún</td></tr>'}
          </tbody>
        </table>
      </body>
      </html>
    `);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al cargar el panel de compras');
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend corriendo en http://localhost:${PORT}`);
  console.log(`Ver compras en http://localhost:${PORT}/compras`);
});
