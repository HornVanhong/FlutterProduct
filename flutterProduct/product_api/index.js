require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { sql, config } = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

app.get("/products", async (req, res) => {
  try {
    await sql.connect(config);
    const id = req.query.id;
    const result = await sql.query(
      id
        ? `SELECT * FROM PRODUCTS WHERE PRODUCTID = ${id}`
        : "SELECT * FROM PRODUCTS"
    );
    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/products", async (req, res) => {
  try {
    const { PRODUCTNAME, PRICE, STOCK } = req.body;
    if (!PRODUCTNAME || PRICE <= 0 || STOCK < 0) {
      return res.status(400).json({ error: "Invalid input" });
    }

    await sql.connect(config);
    await sql.query`INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK) VALUES (${PRODUCTNAME}, ${PRICE}, ${STOCK})`;
    res.status(201).json({ message: "Product created" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put("/products", async (req, res) => {
  try {
    const id = req.query.id;
    const { PRODUCTNAME, PRICE, STOCK } = req.body;

    if (!id || !PRODUCTNAME || PRICE <= 0 || STOCK < 0) {
      return res.status(400).json({ error: "Invalid input" });
    }

    await sql.connect(config);
    await sql.query`UPDATE PRODUCTS SET PRODUCTNAME = ${PRODUCTNAME}, PRICE = ${PRICE}, STOCK = ${STOCK} WHERE PRODUCTID = ${id}`;
    res.status(200).json({ message: "Product updated" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete("/products", async (req, res) => {
  try {
    const id = req.query.id;
    if (!id) return res.status(400).json({ error: "No ID" });

    await sql.connect(config);
    await sql.query`DELETE FROM PRODUCTS WHERE PRODUCTID = ${id}`;
    res.status(200).json({ message: "Product deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(3000, () => console.log("API running at http://localhost:3000"));
