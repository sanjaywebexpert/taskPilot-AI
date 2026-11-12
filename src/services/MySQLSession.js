
import pool from "../config/db.js";

export class MySQLSession {
  constructor(conversationId) {
    this.conversationId = conversationId;
  }

  async getSessionId() {
    return this.conversationId;
  }

  async getItems(limit) {
    let sql = `
      SELECT item_data
      FROM conversation_items
      WHERE conversation_id = ?
      ORDER BY id ASC
    `;

    const params = [this.conversationId];

    if (limit !== undefined) {
      if (!Number.isInteger(limit) || limit < 0) {
        throw new Error("Invalid history limit");
      }

      if (limit === 0) return [];

      sql = `
        SELECT item_data
        FROM (
          SELECT id, item_data
          FROM conversation_items
          WHERE conversation_id = ?
          ORDER BY id DESC
          LIMIT ${limit}
        ) AS recent
        ORDER BY id ASC
      `;
    }

    const [rows] = await pool.execute(sql, params);

    return rows.map((row) =>
      typeof row.item_data === "string"
        ? JSON.parse(row.item_data)
        : row.item_data
    );
  }

  async addItems(items) {
    if (!items.length) return;

    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      for (const item of items) {
        await connection.execute(
          `INSERT INTO conversation_items
           (conversation_id, item_data)
           VALUES (?, ?)`,
          [
            this.conversationId,
            JSON.stringify(item)
          ]
        );
      }

      await connection.execute(
        `UPDATE conversations
         SET updated_at = CURRENT_TIMESTAMP
         WHERE id = ?`,
        [this.conversationId]
      );

      await connection.commit();

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  async popItem() {
    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      const [rows] = await connection.execute(
        `SELECT id, item_data
         FROM conversation_items
         WHERE conversation_id = ?
         ORDER BY id DESC
         LIMIT 1
         FOR UPDATE`,
        [this.conversationId]
      );

      if (!rows.length) {
        await connection.commit();
        return undefined;
      }

      await connection.execute(
        "DELETE FROM conversation_items WHERE id = ?",
        [rows[0].id]
      );

      await connection.commit();

      const item = rows[0].item_data;

      return typeof item === "string"
        ? JSON.parse(item)
        : item;

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  async clearSession() {
    await pool.execute(
      `DELETE FROM conversation_items
       WHERE conversation_id = ?`,
      [this.conversationId]
    );
  }
}
