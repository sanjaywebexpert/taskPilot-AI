
import { tool } from "@openai/agents";
import { z } from "zod";
import pool from "../config/db.js";
import { createHash } from "node:crypto";
import { requestContext } from "../services/requestContext.js";

export const createTaskTool = tool({
  name: "create_task",
  description:
    "Create a new task in MySQL. Use when the user asks to add or create a task.",

  parameters: z.object({
    title: z.string().min(1).max(255),
    description: z.string().nullable(),
    priority: z.enum(["low", "medium", "high"]),
    due_date: z.string().nullable()
  }),

  /*async execute({
    title,
    description,
    priority,
    due_date
  }) {
    try {
      if (
        process.env.NODE_ENV !== "production" &&
        process.env.SIMULATE_CREATE_TASK_FAILURE === "true"
      ) {
        throw new Error("Simulated database failure");
      }

      if (due_date !== null) {
        const validDateFormat = /^\d{4}-\d{2}-\d{2}$/.test(due_date);

        const parsedDate = new Date(`${due_date}T00:00:00Z`);

        if (
          !validDateFormat ||
          Number.isNaN(parsedDate.getTime()) ||
          parsedDate.toISOString().slice(0, 10) !== due_date
        ) {
          return {
            success: false,
            message: "Invalid due date. Use YYYY-MM-DD."
          };
        }
      }


      const sql = `
        INSERT INTO tasks
        (title, description, priority, due_date)
        VALUES (?, ?, ?, ?)
      `;

      const [result] = await pool.execute(sql, [
        title.trim(),
        description,
        priority,
        due_date
      ]);
      console.log("create_task executed:", result.insertId);

      return {
        success: true,
        task_id: result.insertId,
        title: title.trim(),
        priority,
        due_date,
        message: "Task created successfully"
      };
    } catch (error) {
      console.error("create_task database error:", error);

      return {
        success: false,
        error_code: "DATABASE_OPERATION_FAILED",
        message: "Task could not be saved. Please try again later."
      };
    }

  }
*/


async execute({ title, description, priority, due_date }) {
  const context = requestContext.getStore();

  if (!context?.idempotencyKey) {
    return {
      success: false,
      error_code: "IDEMPOTENCY_KEY_REQUIRED",
      message: "Task creation requires an Idempotency-Key header."
    };
  }

  // This checkpoint supports one create operation per HTTP request.
  context.createCalls++;

  if (context.createCalls > 1) {
    return {
      success: false,
      error_code: "MULTIPLE_CREATES_NOT_SUPPORTED",
      message: "Create one task per request for now."
    };
  }

  // Validate date before accessing MySQL.
  if (due_date !== null) {
    const validFormat = /^\d{4}-\d{2}-\d{2}$/.test(due_date);
    const date = new Date(`${due_date}T00:00:00Z`);

    if (
      !validFormat ||
      Number.isNaN(date.getTime()) ||
      date.toISOString().slice(0, 10) !== due_date
    ) {
      return {
        success: false,
        error_code: "INVALID_DUE_DATE",
        message: "Invalid due date. Use YYYY-MM-DD."
      };
    }
  }

  const normalizedTitle = title.trim();

  if (!normalizedTitle) {
    return {
      success: false,
      message: "Task title cannot be empty"
    };
  }

  // Hash the validated business payload.
  const payload = {
    title: normalizedTitle,
    description,
    priority,
    due_date
  };

  const requestHash = createHash("sha256")
    .update(JSON.stringify(payload))
    .digest("hex");

  const idempotencyKey = context.idempotencyKey;

  try {
    const sql = `
      INSERT INTO tasks
      (
        title,
        description,
        priority,
        due_date,
        idempotency_key,
        request_hash
      )
      VALUES (?, ?, ?, ?, ?, ?)
    `;

    const [result] = await pool.execute(sql, [
      normalizedTitle,
      description,
      priority,
      due_date,
      idempotencyKey,
      requestHash
    ]);

    console.log("create_task inserted:", result.insertId);

    return {
      success: true,
      duplicate: false,
      task_id: result.insertId,
      message: "Task created successfully"
    };

  } catch (error) {

    // A unique-key conflict may indicate a retried request.
    if (
      error.code === "ER_DUP_ENTRY" &&
      error.message?.includes("uq_task_idempotency")
    ) {
      try {
        const [rows] = await pool.execute(
          `SELECT id, request_hash
           FROM tasks
           WHERE idempotency_key = ?`,
          [idempotencyKey]
        );

        if (!rows.length) {
          return {
            success: false,
            error_code: "RETRY_STATE_UNAVAILABLE",
            message: "Unable to verify the previous request."
          };
        }

        // Prevent reusing the same key for another payload.
        if (rows[0].request_hash !== requestHash) {
          return {
            success: false,
            error_code: "IDEMPOTENCY_CONFLICT",
            message: "This key was already used with different task details."
          };
        }

        console.log("create_task replay:", rows[0].id);

        return {
          success: true,
          duplicate: true,
          task_id: rows[0].id,
          message: "Task already created by an earlier request"
        };

      } catch (lookupError) {
        console.error("Idempotency lookup failed:", lookupError);

        return {
          success: false,
          error_code: "RETRY_VERIFICATION_FAILED",
          message: "Unable to verify whether the task was created."
        };
      }
    }

    console.error("create_task failed:", error);

    return {
      success: false,
      error_code: "DATABASE_OPERATION_FAILED",
      message: "Unable to confirm task creation. Do not retry with a new key."
    };
  }
}
});
