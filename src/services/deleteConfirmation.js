
import { randomBytes } from "node:crypto";

const pendingDeletes = new Map();

const EXPIRY_MS = 5 * 60 * 1000;

export function createDeleteConfirmation(taskId) {
  const token = randomBytes(32).toString("hex");

  pendingDeletes.set(token, {
    taskId,
    expiresAt: Date.now() + EXPIRY_MS
  });

  return {
    token,
    expires_in_seconds: 300
  };
}

export function consumeDeleteConfirmation(token) {
  const request = pendingDeletes.get(token);

  if (!request) {
    return null;
  }

  // Single-use token
  pendingDeletes.delete(token);

  if (Date.now() > request.expiresAt) {
    return null;
  }

  return request;
}
