
import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import pool from "./config/db.js";
import { taskAgent } from "./agents/taskAgent.js";
import { run, InputGuardrailTripwireTriggered  } from "@openai/agents";
import { chatSchema } from "./validators/chatValidator.js";
import { consumeDeleteConfirmation } from "./services/deleteConfirmation.js";
import { createSession, getSession } from "./services/sessionManager.js";
import { requestContext } from "./services/requestContext.js";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Health check endpoint
app.get("/api/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "TaskPilot AI server is running"
  });
});

app.get("/api/db-health", async (req, res) => {
  try {
    const [rows] = await pool.execute("SELECT * FROM tasks");
    res.status(200).json(
        {
            success: true,
            message: "Database is connected",
            data: rows
        }
    );
  } catch (error) {
    console.error("Database connection error:", error);
    res.status(500).json({ 
        success: false,
        message: "Database connection error",
        error: error.message
     });
    
  }
});

app.post("/api/chat-old-way", async (req, res) => {
    try {
        const { message } = req.body ?? {};
        if (
            typeof message !== "string" ||
            message.trim().length === 0 ||
            message.length > 2000
          ) {
            return res.status(400).json({
              success: false,
              message: "Message must be 1-2000 characters"
            });
          }
          const result = await run(
            taskAgent,
            message.trim()
          );
      
          return res.status(200).json({
            success: true,
            agent: "TaskPilot AI",
            response: result.finalOutput
          });

    } catch (error) {
        console.error("AI Agent Error:", error);

        return res.status(500).json({
        success: false,
        message: "AI agent request failed"
        });
    }

});


app.post("/api/chat", async (req, res) => {
  try {

    const validation = chatSchema.safeParse(req.body);

    if (!validation.success) {
      return res.status(400).json({
        success: false,
        message: "Invalid request data",
        errors: validation.error.issues.map(issue => ({
          field: issue.path.join("."),
          message: issue.message
        }))
      });
    }

    const { message, conversationId } = validation.data;

    //const { message, conversationId } = req.body ?? {};

    // 1. Validate message
    if (
      typeof message !== "string" ||
      !message.trim() ||
      message.length > 2000
    ) {
      return res.status(400).json({
        success: false,
        message: "Message must be 1-2000 characters"
      });
    }

    
    const rawKey = req.get("Idempotency-Key");

    if (
      rawKey !== undefined &&
      (
        rawKey.length < 8 ||
        rawKey.length > 100 ||
        !/^[A-Za-z0-9_-]+$/.test(rawKey)
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid Idempotency-Key header"
      });
    }


    // 2. Create or retrieve conversation session
    let activeConversationId;
    let session;

    if (conversationId == null) {
      const created = await createSession();

      activeConversationId = created.conversationId;
      session = created.session;
    } else {
      if (
        typeof conversationId !== "string" ||
        !/^[0-9a-f-]{36}$/i.test(conversationId)
      ) {
        return res.status(400).json({
          success: false,
          message: "Invalid conversation ID"
        });
      }

      session = await getSession(conversationId);

      if (!session) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found"
        });
      }

      activeConversationId = conversationId;
    }

    // 3. Run agent with conversation memory
    const result = await requestContext.run(
      {
        idempotencyKey: rawKey ?? null,
        createCalls: 0
      },
      async () => {
        return await run(
          taskAgent,
          message,
          { session }
        );
      }
    );


    // 4. Return response and conversation ID
    return res.status(200).json({
      success: true,
      conversationId: activeConversationId,
      agent: "TaskPilot AI",
      response: result.finalOutput
    });

  } catch (error) {
    if (error instanceof InputGuardrailTripwireTriggered) {
      return res.status(403).json({
        success: false,
        code: "INPUT_GUARDRAIL_BLOCKED",
        message: "Request blocked by agent security policy"
      });
    }
    console.error("AI Agent Error:", error);
    return res.status(500).json({
      success: false,
      message: "AI agent request failed"
    });
  }
});


app.post("/api/tasks/confirm-delete", async (req, res) => {
    try {
      const { confirmation_token } = req.body ?? {};
  
      if (
        typeof confirmation_token !== "string" ||
        !/^[a-f0-9]{64}$/.test(confirmation_token)
      ) {
        return res.status(400).json({
          success: false,
          message: "Invalid confirmation token"
        });
      }
  
      // Validate and consume the single-use token
      const confirmation =
        consumeDeleteConfirmation(confirmation_token);
  
      if (!confirmation) {
        return res.status(400).json({
          success: false,
          message: "Confirmation token invalid, expired or used"
        });
      }
  
      // The task ID comes from the verified token,
      // not from user-supplied request parameters.
      const taskId = confirmation.taskId;
  
      const [result] = await pool.execute(
        "DELETE FROM tasks WHERE id = ?",
        [taskId]
      );
  
      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: "Task not found or already deleted"
        });
      }
  
      return res.status(200).json({
        success: true,
        message: `Task ${taskId} deleted successfully`,
        deleted_task_id: taskId
      });
  
    } catch (error) {
      console.error("Delete confirmation failed:", error);
  
      return res.status(500).json({
        success: false,
        message: "Unable to delete task"
      });
    }
});
  
// This endpoint reads your existing MySQL history without changing how the Agents SDK stores it.
app.get("/api/conversations/:id/messages", async (req, res) => {
  try {
    const { id } = req.params;

    // Validate UUID
    if (
      !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(id)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid conversation ID"
      });
    }

    // Check conversation exists
    const [conversations] = await pool.execute(
      "SELECT id FROM conversations WHERE id = ?",
      [id]
    );

    if (conversations.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found"
      });
    }

    const [rows] = await pool.execute(
      `SELECT item_data
       FROM conversation_items
       WHERE conversation_id = ?
       ORDER BY id ASC`,
      [id]
    );

    const messages = [];

    for (const row of rows) {
      const item = typeof row.item_data === "string"
        ? JSON.parse(row.item_data)
        : row.item_data;

      // Ignore function calls and tool results
      if (item.type === "function_call" ||
          item.type === "function_call_result") {
        continue;
      }

      if (item.role !== "user" && item.role !== "assistant") {
        continue;
      }

      let content = "";

      if (typeof item.content === "string") {
        content = item.content;
      } else if (Array.isArray(item.content)) {
        content = item.content
          .filter(part =>
            (part.type === "input_text" ||
             part.type === "output_text") &&
            typeof part.text === "string"
          )
          .map(part => part.text)
          .join("\n");
      }

      if (content.trim()) {
        messages.push({
          role: item.role,
          content
        });
      }
    }

    return res.status(200).json({
      success: true,
      conversationId: id,
      messages
    });

  } catch (error) {
    console.error("Conversation retrieval failed:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve conversation"
    });
  }
});


app.get("/api/conversations", async (req, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT
        c.id,
        c.created_at,
        c.updated_at,

        (
          SELECT JSON_UNQUOTE(
            JSON_EXTRACT(ci.item_data, '$.content')
          )
          FROM conversation_items ci
          WHERE ci.conversation_id = c.id
            AND JSON_UNQUOTE(
              JSON_EXTRACT(ci.item_data, '$.role')
            ) = 'user'
          ORDER BY ci.id ASC
          LIMIT 1
        ) AS first_message

      FROM conversations c
      ORDER BY c.updated_at DESC, c.id DESC
      LIMIT 50
    `);

    const conversations = rows.map(row => {
      const firstMessage =
        typeof row.first_message === "string"
          ? row.first_message.trim()
          : "";

      return {
        id: row.id,
        title: firstMessage
          ? firstMessage.slice(0, 60)
          : "New Conversation",
        created_at: row.created_at,
        updated_at: row.updated_at
      };
    });

    return res.status(200).json({
      success: true,
      count: conversations.length,
      conversations
    });

  } catch (error) {
    console.error("List conversations error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve conversations"
    });
  }
});

app.listen(PORT, () => {
  console.log(`okk Server running on port ${PORT}`);
});
