
import { MemorySession } from "@openai/agents";
import { randomUUID } from "node:crypto";

// Store conversations in application memory
const sessions = new Map();

export function createSession() {
  const conversationId = randomUUID();

  const session = new MemorySession({
    sessionId: conversationId
  });

  sessions.set(conversationId, session);

  return {
    conversationId,
    session
  };
}

export function getSession(conversationId) {
  return sessions.get(conversationId) || null;
}
