
import { tool } from "@openai/agents";
import { z } from "zod";
import pool from "../config/db.js";

export const getTasksTool = tool({
  name: "get_tasks",

  description: `
    Retrieve existing tasks from MySQL.
    Use when the user asks to list, show,
    find, or view tasks.
    Supports filtering by status and priority.
    Use null when a filter is not specified.
  `,

  parameters: z.object({
    status: z.enum([
      "pending",
      "in_progress",
      "completed"
    ]).nullable(),

    priority: z.enum([
      "low",
      "medium",
      "high"
    ]).nullable()
  }),

  async execute({ status, priority }) {
    try {
      const sql = `
        SELECT
          id,
          title,
          description,
          status,
          priority,
          DATE_FORMAT(due_date, '%Y-%m-%d') AS due_date,
          completed_at
        FROM tasks
        WHERE (? IS NULL OR status = ?)
          AND (? IS NULL OR priority = ?)
        ORDER BY id DESC
        LIMIT 20
      `;

      const [rows] = await pool.execute(sql, [
        status, status,
        priority, priority
      ]);

      console.log("get_tasks executed:", {
        status,
        priority,
        returned: rows.length
      });

      return {
        success: true,
        count: rows.length,
        tasks: rows,
        limit: 20
      };

    } catch (error) {
      console.error("get_tasks failed:", error);

      return {
        success: false,
        message: "Unable to retrieve tasks"
      };
    }
  }
});
