
import { tool } from "@openai/agents";
import { z } from "zod";
import pool from "../config/db.js";

export const updateTaskTool = tool({
  name: "update_task",
  description: `
    Update an existing task in MySQL using its task ID.

    Use this tool when the user asks to modify
    a task's title, description, priority or due date.

    Pass null for fields the user does not want
    to change.

    Do not use this tool to complete or delete tasks.
  `,

  parameters: z.object({
    task_id: z.number().int().positive(),

    title: z.string().min(1).max(255).nullable(),

    description: z.string().nullable(),

    priority: z.enum([
      "low",
      "medium",
      "high"
    ]).nullable(),

    due_date: z.string().nullable()
  }),

  async execute({
    task_id,
    title,
    description,
    priority,
    due_date
  }) {

    try {
      // 1. Check whether task exists
      const [existingTasks] = await pool.execute(
        "SELECT id FROM tasks WHERE id = ?",
        [task_id]
      );

      if (existingTasks.length === 0) {
        return {
          success: false,
          message: `Task ${task_id} not found`
        };
      }

      // 2. Prepare partial update
      const updates = [];
      const values = [];

      if (title !== null) {
        if (!title.trim()) {
          return {
            success: false,
            message: "Task title cannot be empty"
          };
        }
        updates.push("title = ?");
        values.push(title.trim());
      }
      if (description !== null) {
        updates.push("description = ?");
        values.push(description);
      }
      if (priority !== null) {
        updates.push("priority = ?");
        values.push(priority);
      }
      if (due_date !== null) {
        const validFormat = /^\d{4}-\d{2}-\d{2}$/.test(due_date);

        const parsedDate = new Date(
          `${due_date}T00:00:00Z`
        );

        if (
          !validFormat ||
          Number.isNaN(parsedDate.getTime()) ||
          parsedDate.toISOString().slice(0, 10) !== due_date
        ) {
          return {
            success: false,
            message: "Invalid due date. Use YYYY-MM-DD."
          };
        }

        updates.push("due_date = ?");
        values.push(due_date);
      }

      // 3. Check if anything needs updating
      if (updates.length === 0) {
        return {
          success: false,
          message: "No fields provided for update"
        };
      }

      // 4. Execute update
      values.push(task_id);

      const sql = `
        UPDATE tasks
        SET ${updates.join(", ")}
        WHERE id = ?
      `;

      await pool.execute(sql, values);

      // 5. Retrieve updated task
      const [rows] = await pool.execute(
        `SELECT
           id,
           title,
           description,
           status,
           priority,
           DATE_FORMAT(due_date, '%Y-%m-%d') AS due_date
         FROM tasks
         WHERE id = ?`,
        [task_id]
      );

      console.log("update_task executed:", task_id);

      return {
        success: true,
        message: "Task updated successfully",
        task: rows[0]
      };

    } catch (error) {
      console.error("update_task error:", error);

      return {
        success: false,
        message: "Unable to update task"
      };
    }
  }
});
