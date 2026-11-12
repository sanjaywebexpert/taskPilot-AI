
import "dotenv/config";
import test from "node:test";
import assert from "node:assert/strict";
import mysql from "mysql2/promise";
import { randomUUID } from "node:crypto";

const BASE_URL = "http://localhost:3000";

const db = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  connectionLimit: 2
});


async function sendMessage(
    message,
    conversationId = null,
    idempotencyKey = null
  ) {
    const response = await fetch(`${BASE_URL}/api/chat`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        ...(idempotencyKey
          ? { "Idempotency-Key": idempotencyKey }
          : {})
      },
      body: JSON.stringify({
        message,
        ...(conversationId ? { conversationId } : {})
      }),
      signal: AbortSignal.timeout(60000)
    });
  
    return {
      status: response.status,
      data: await response.json()
    };
  }
  

// Read the actual tool calls saved by the Agents SDK.
async function getToolCalls(conversationId) {
  const [rows] = await db.execute(
    `SELECT item_data
     FROM conversation_items
     WHERE conversation_id = ?
     ORDER BY id ASC`,
    [conversationId]
  );

  return rows
    .map(row =>
      typeof row.item_data === "string"
        ? JSON.parse(row.item_data)
        : row.item_data
    )
    .filter(item => item.type === "function_call")
    .map(item => ({
      name: item.name,
      arguments: JSON.parse(item.arguments || "{}")
    }));
}

async function getTaskCount() {
  const [rows] = await db.execute(
    "SELECT COUNT(*) AS total FROM tasks"
  );

  return rows[0].total;
}

// EVAL-007: Verify correct tool selection and filters.
test("EVAL-007: get_tasks selected with correct filters", async () => {
  const beforeCount = await getTaskCount();

  const result = await sendMessage(
    "Show all my high-priority pending tasks. Include their IDs."
  );

  assert.equal(result.status, 200);
  assert.equal(result.data.success, true);
  assert.ok(result.data.conversationId);

  const calls = await getToolCalls(result.data.conversationId);

  console.log("Actual tool calls:", calls);

  assert.equal(calls.length, 1);
  assert.equal(calls[0].name, "get_tasks");

  assert.equal(calls[0].arguments.status, "pending");
  assert.equal(calls[0].arguments.priority, "high");

  const afterCount = await getTaskCount();

  assert.equal(afterCount, beforeCount);

  console.log("PASS: Correct get_tasks tool and filters");
});

// EVAL-008: Normal explanation should need no tools.
test("EVAL-008: General explanation requires no tool", async () => {
  const beforeCount = await getTaskCount();

  const result = await sendMessage(
    "Explain what task prioritization means in simple terms. Do not access my tasks."
  );

  assert.equal(result.status, 200);
  assert.equal(result.data.success, true);

  const calls = await getToolCalls(result.data.conversationId);

  console.log("Actual tool calls:", calls);

  assert.equal(calls.length, 0);

  assert.ok(
    typeof result.data.response === "string" &&
    result.data.response.length > 0
  );

  const afterCount = await getTaskCount();

  assert.equal(afterCount, beforeCount);

  console.log("PASS: No unnecessary tool execution");
});




test("EVAL-009: create_task inserts correct MySQL record", async () => {
    const idempotencyKey = `eval-${randomUUID()}`;
    const taskTitle = `AI Evaluation ${randomUUID().slice(0, 8)}`;
  
    try {
      const beforeCount = await getTaskCount();
  
      // 1. Ask the agent to create a task
      const result = await sendMessage(
        `Create a high-priority task with the exact title "${taskTitle}". No description and no due date.`,
        null,
        idempotencyKey
      );
  
      assert.equal(result.status, 200);
      assert.equal(result.data.success, true);
  
      // 2. Verify agent tool selection
      const calls = await getToolCalls(
        result.data.conversationId
      );
  
      console.log("Actual tool calls:", calls);
  
      assert.equal(calls.length, 1);
      assert.equal(calls[0].name, "create_task");
  
      assert.equal(
        calls[0].arguments.title,
        taskTitle
      );
  
      assert.equal(
        calls[0].arguments.priority,
        "high"
      );
  
      // 3. Verify the actual MySQL record
      const [rows] = await db.execute(
        `SELECT id, title, priority, status
         FROM tasks
         WHERE idempotency_key = ?`,
        [idempotencyKey]
      );
  
      assert.equal(rows.length, 1);
      assert.equal(rows[0].title, taskTitle);
      assert.equal(rows[0].priority, "high");
      assert.equal(rows[0].status, "pending");
  
      const afterCount = await getTaskCount();
  
      assert.equal(afterCount, beforeCount + 1);
  
      console.log("PASS: create_task database evaluation");
      console.log("Created test task:", rows[0].id);
  
    } finally {
      // Cleanup by the exact evaluation key.
      // Never delete unrelated tasks.
      const [cleanup] = await db.execute(
        `DELETE FROM tasks
         WHERE idempotency_key = ?
           AND title = ?`,
        [idempotencyKey, taskTitle]
      );
  
      console.log(
        "EVAL-009 cleanup rows:",
        cleanup.affectedRows
      );
    }
  });
  

  test("EVAL-010: update_task modifies only requested fields", async () => {
    const title = `EVAL Update ${Date.now()}`;
    let taskId = null;
  
    try {
      // 1. Create a temporary test task directly in MySQL
      const [insertResult] = await db.execute(
        `INSERT INTO tasks
         (title, description, status, priority, due_date)
         VALUES (?, ?, ?, ?, ?)`,
        [
          title,
          "Temporary task for update evaluation",
          "pending",
          "medium",
          null
        ]
      );
  
      taskId = insertResult.insertId;
  
      console.log("Temporary task created:", taskId);
  
      const beforeCount = await getTaskCount();
  
      // 2. Ask the AI agent to update the task
      const result = await sendMessage(
        `Update task ID ${taskId}. Change only its priority to high. Keep all other fields unchanged.`
      );
  
      assert.equal(result.status, 200);
      assert.equal(result.data.success, true);
  
      // 3. Inspect actual tool calls
      const calls = await getToolCalls(
        result.data.conversationId
      );
  
      console.log("Actual tool calls:", calls);
  
      const updateCalls = calls.filter(
        call => call.name === "update_task"
      );
  
      assert.equal(
        updateCalls.length,
        1,
        "Agent should call update_task exactly once"
      );
  
      assert.equal(updateCalls[0].arguments.task_id, taskId);
      assert.equal(updateCalls[0].arguments.priority, "high");
  
      // No other business operation should execute
      assert.equal(calls.length, 1);
  
      // 4. Verify the saved database values
      const [rows] = await db.execute(
        `SELECT id, title, description,
                status, priority, due_date
         FROM tasks
         WHERE id = ?`,
        [taskId]
      );
  
      assert.equal(rows.length, 1);
      assert.equal(rows[0].id, taskId);
      assert.equal(rows[0].priority, "high");
      assert.equal(rows[0].status, "pending");
      assert.equal(rows[0].title, title);
  
      assert.equal(
        rows[0].description,
        "Temporary task for update evaluation"
      );
  
      assert.equal(rows[0].due_date, null);
  
      // 5. Verify no additional task was created
      const afterCount = await getTaskCount();
      assert.equal(afterCount, beforeCount);
  
      console.log("PASS: update_task database evaluation");
  
    } finally {
      // 6. Cleanup only the temporary test record
      if (taskId !== null) {
        await db.execute(
          "DELETE FROM tasks WHERE id = ?",
          [taskId]
        );
  
        console.log("Temporary task cleaned up:", taskId);
      }
    }
  });
    

  test("EVAL-011: complete_task is idempotent", async () => {
    const title = `EVAL Complete ${Date.now()}`;
    let taskId = null;
  
    try {
      // 1. Create a temporary pending task
      const [insertResult] = await db.execute(
        `INSERT INTO tasks
         (title, status, priority, completed_at)
         VALUES (?, 'pending', 'medium', NULL)`,
        [title]
      );
  
      taskId = insertResult.insertId;
  
      console.log("Temporary task created:", taskId);
  
      // 2. Ask the AI agent to complete it
      const firstResult = await sendMessage(
        `Mark task ID ${taskId} as completed.`
      );
  
      assert.equal(firstResult.status, 200);
      assert.equal(firstResult.data.success, true);
  
      // 3. Verify the correct tool was called
      const firstCalls = await getToolCalls(
        firstResult.data.conversationId
      );
  
      console.log("First tool calls:", firstCalls);
  
      assert.equal(firstCalls.length, 1);
      assert.equal(firstCalls[0].name, "complete_task");
      assert.equal(
        firstCalls[0].arguments.task_id,
        taskId
      );
  
      // 4. Verify completed task in MySQL
      const [firstRows] = await db.execute(
        `SELECT
           id, title, status, priority,
           DATE_FORMAT(
             completed_at,
             '%Y-%m-%d %H:%i:%s'
           ) AS completed_at
         FROM tasks
         WHERE id = ?`,
        [taskId]
      );
  
      assert.equal(firstRows.length, 1);
      assert.equal(firstRows[0].status, "completed");
      assert.ok(firstRows[0].completed_at);
  
      const firstCompletedAt = firstRows[0].completed_at;
  
      console.log("First completion time:", firstCompletedAt);
  
      // 5. Repeat the completion request
      const secondResult = await sendMessage(
        `Mark task ID ${taskId} as completed again.
         If already completed, tell me.`
      );
  
      assert.equal(secondResult.status, 200);
      assert.equal(secondResult.data.success, true);
  
      const secondCalls = await getToolCalls(
        secondResult.data.conversationId
      );
  
      console.log("Second tool calls:", secondCalls);
  
      assert.equal(secondCalls.length, 1);
      assert.equal(secondCalls[0].name, "complete_task");
      assert.equal(
        secondCalls[0].arguments.task_id,
        taskId
      );
  
      // 6. Check the completion timestamp again
      const [secondRows] = await db.execute(
        `SELECT
           id, title, status, priority,
           DATE_FORMAT(
             completed_at,
             '%Y-%m-%d %H:%i:%s'
           ) AS completed_at
         FROM tasks
         WHERE id = ?`,
        [taskId]
      );
  
      assert.equal(secondRows.length, 1);
      assert.equal(secondRows[0].status, "completed");
  
      assert.equal(
        secondRows[0].completed_at,
        firstCompletedAt,
        "Completion timestamp must not change"
      );
  
      assert.equal(secondRows[0].title, title);
      assert.equal(secondRows[0].priority, "medium");
  
      console.log("PASS: complete_task is idempotent");
      console.log("Timestamp preserved:", firstCompletedAt);
  
    } finally {
      // Clean up the temporary task
      if (taskId !== null) {
        await db.execute(
          "DELETE FROM tasks WHERE id = ?",
          [taskId]
        );
  
        console.log("Temporary task cleaned up:", taskId);
      }
    }
  });

  test("EVAL-013: Agent remembers conversation context", async () => {

    // 1. Generate unique reference for this test
    const referenceCode =
      `PROJECT-${randomUUID().slice(0, 8).toUpperCase()}`;
  
    // 2. Start a new conversation
    const firstResult = await sendMessage(
      `My project reference code is ${referenceCode}.
       Remember this code for our conversation.
       Do not create or update any tasks.`
    );
  
    assert.equal(firstResult.status, 200);
    assert.equal(firstResult.data.success, true);
  
    const conversationId = firstResult.data.conversationId;
  
    assert.ok(conversationId);
  
    console.log("Conversation ID:", conversationId);
    console.log("Reference code:", referenceCode);
  
    // 3. Continue the SAME conversation
    const secondResult = await sendMessage(
      "What project reference code did I mention earlier? Reply with the exact code only.",
      conversationId
    );
  
    assert.equal(secondResult.status, 200);
    assert.equal(secondResult.data.success, true);
  
    assert.equal(
      secondResult.data.conversationId,
      conversationId
    );
  
    const actualAnswer =
      secondResult.data.response.trim();
  
    console.log("Agent recalled:", actualAnswer);
  
    assert.equal(
      actualAnswer,
      referenceCode,
      "Agent must remember the correct reference code"
    );
  
    // 4. Verify that no tools were used
    const calls = await getToolCalls(conversationId);
  
    console.log("Tool calls:", calls);
  
    assert.equal(
      calls.length,
      0,
      "Memory test should not require task tools"
    );
  
    // 5. Verify the conversation was persisted
    const [rows] = await db.execute(
      `SELECT COUNT(*) AS total
       FROM conversation_items
       WHERE conversation_id = ?`,
      [conversationId]
    );
  
    assert.ok(
      rows[0].total >= 4,
      "Both user messages and agent responses should be stored"
    );
  
    console.log("PASS: Conversation memory verified");
  });
  
  test("EVAL-012: delete requires backend confirmation", async () => {
    const title = `EVAL Delete ${Date.now()}`;
    let taskId = null;
  
    try {
      // 1. Create a disposable test task
      const [insertResult] = await db.execute(
        `INSERT INTO tasks
         (title, status, priority)
         VALUES (?, 'pending', 'low')`,
        [title]
      );
  
      taskId = insertResult.insertId;
  
      console.log("Temporary task created:", taskId);
  
      const beforeCount = await getTaskCount();
  
      // 2. Ask the agent to delete this task
      const result = await sendMessage(
        `Delete task ID ${taskId}.`
      );
  
      assert.equal(result.status, 200);
      assert.equal(result.data.success, true);
  
      // 3. Inspect the actual agent tool call
      const calls = await getToolCalls(
        result.data.conversationId
      );
  
      console.log("Tool names:", calls.map(call => call.name));
  
      assert.equal(
        calls.length,
        1,
        "Agent should call exactly one tool"
      );
  
      assert.equal(
        calls[0].name,
        "prepare_delete_task"
      );
  
      assert.equal(
        calls[0].arguments.task_id,
        taskId
      );
  
      // 4. Verify the original task still exists
      const [rows] = await db.execute(
        `SELECT id, title, status, priority
         FROM tasks
         WHERE id = ?`,
        [taskId]
      );
  
      assert.equal(
        rows.length,
        1,
        "Task must not be deleted before confirmation"
      );
  
      assert.equal(rows[0].id, taskId);
      assert.equal(rows[0].title, title);
      assert.equal(rows[0].status, "pending");
      assert.equal(rows[0].priority, "low");
  
      // 5. Verify total task count unchanged
      const afterCount = await getTaskCount();
  
      assert.equal(
        afterCount,
        beforeCount,
        "Preparing deletion must not remove records"
      );
  
      // 6. Verify the agent communicates confirmation
      assert.equal(
        typeof result.data.response,
        "string"
      );
  
      assert.match(
        result.data.response,
        /confirm|confirmation|token/i
      );
  
      console.log(
        "PASS: Deletion prepared without deleting task"
      );
  
    } finally {
      // 7. Cleanup only our disposable fixture
      if (taskId !== null) {
        await db.execute(
          "DELETE FROM tasks WHERE id = ?",
          [taskId]
        );
  
        console.log("Temporary task cleaned up:", taskId);
      }
    }
  });
    
test.after(async () => {
  await db.end();
});
