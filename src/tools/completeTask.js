
import { tool } from "@openai/agents";
import { z } from "zod";
import pool from "../config/db.js";

export const completeTaskTool = tool({
  name: "complete_task",

  description: `
    Mark an existing task as completed using its task ID.

    Use this tool when the user explicitly asks to
    complete, finish, or mark a task as done.

    Do not use this tool to create, edit, or delete tasks.
    A valid task ID is required.
  `,

  parameters: z.object({
    task_id: z.number().int().positive()
  }),

  async execute({ task_id }) {
    try {
      // 1. Update only if task is not already completed
      const [result] = await pool.execute(
        `UPDATE tasks
         SET status = 'completed',
             completed_at = CURRENT_TIMESTAMP
         WHERE id = ?
           AND status <> 'completed'`,
        [task_id]
      );

      // 2. Retrieve the current task state
      const [rows] = await pool.execute(
        `SELECT
           id,
           title,
           status,
           priority,
           DATE_FORMAT(due_date, '%Y-%m-%d') AS due_date,
           DATE_FORMAT(
             completed_at,
             '%Y-%m-%d %H:%i:%s'
           ) AS completed_at
         FROM tasks
         WHERE id = ?`,
        [task_id]
      );

      // 3. Task does not exist
      if (rows.length === 0) {
        return {
          success: false,
          message: `Task ${task_id} not found`
        };
      }

      // 4. Task was already completed
      if (result.affectedRows === 0) {
        return {
          success: true,
          already_completed: true,
          message: `Task ${task_id} was already completed`,
          task: rows[0]
        };
      }

      console.log("complete_task executed:", task_id);

      // 5. Return updated task
      return {
        success: true,
        already_completed: false,
        message: "Task completed successfully",
        task: rows[0]
      };

    } catch (error) {
      console.error("complete_task error:", error);

      return {
        success: false,
        message: "Unable to complete task"
      };
    }
  }
});
