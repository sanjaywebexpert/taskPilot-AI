
import { tool } from "@openai/agents";
import { z } from "zod";
import pool from "../config/db.js";

import {
  createDeleteConfirmation
} from "../services/deleteConfirmation.js";

export const prepareDeleteTaskTool = tool({
  name: "prepare_delete_task",

  description: `
    Prepare deletion of an existing task.

    This tool DOES NOT delete the task.
    It creates a confirmation token.

    Use only when the user requests task deletion.
    A task ID is required.
  `,

  parameters: z.object({
    task_id: z.number().int().positive()
  }),

  async execute({ task_id }) {
    try {
      const [rows] = await pool.execute(
        "SELECT id, title FROM tasks WHERE id = ?",
        [task_id]
      );

      if (rows.length === 0) {
        return {
          success: false,
          message: `Task ${task_id} not found`
        };
      }

      const confirmation =
        createDeleteConfirmation(task_id);

      return {
        success: true,
        confirmation_required: true,
        task: rows[0],
        confirmation_token: confirmation.token,
        expires_in_seconds: confirmation.expires_in_seconds,
        message: "Deletion prepared. Task not deleted."
      };

    } catch (error) {
      console.error("prepare_delete_task failed:", error);

      return {
        success: false,
        message: "Unable to prepare task deletion"
      };
    }
  }
});
