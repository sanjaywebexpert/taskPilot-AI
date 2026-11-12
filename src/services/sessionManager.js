
import { randomUUID } from "node:crypto";
import pool from "../config/db.js";
import { MySQLSession } from "./MySQLSession.js";

export async function createSession() {
  const conversationId = randomUUID();

  await pool.execute(
    "INSERT INTO conversations (id) VALUES (?)",
    [conversationId]
  );

  return {
    conversationId,
    session: new MySQLSession(conversationId)
  };
}

export async function getSession(conversationId) {
  const [rows] = await pool.execute(
    "SELECT id FROM conversations WHERE id = ?",
    [conversationId]
  );

  if (rows.length === 0) {
    return null;
  }

  return new MySQLSession(conversationId);
}
