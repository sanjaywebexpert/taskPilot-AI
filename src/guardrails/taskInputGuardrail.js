
function extractUserMessage(input) {
    if (typeof input === "string") {
      return input;
    }
  
    if (!Array.isArray(input)) {
      return "";
    }
  
    // Find the most recent user message
    const userMessage = [...input]
      .reverse()
      .find(item => item.role === "user");
  
    if (!userMessage) {
      return "";
    }
  
    if (typeof userMessage.content === "string") {
      return userMessage.content;
    }
  
    if (Array.isArray(userMessage.content)) {
      return userMessage.content
        .filter(part =>
          part.type === "input_text" &&
          typeof part.text === "string"
        )
        .map(part => part.text)
        .join(" ");
    }
  
    return "";
  }
  
  export const taskInputGuardrail = {
    name: "task_input_security",
    runInParallel: false,
  
    async execute({ input }) {
      const message = extractUserMessage(input);
  
      const restrictedPatterns = [
        /\b(reveal|show|print|expose|disclose)\b.{0,80}\b(system prompt|hidden instructions|api key|secret key)\b/i,
  
        /\b(ignore|bypass)\b.{0,80}\b(instructions|security|guardrails)\b/i
      ];
  
      const blocked = restrictedPatterns.some(
        pattern => pattern.test(message)
      );
  
      console.log("Input guardrail:", {
        inputType: Array.isArray(input)
          ? "array"
          : typeof input,
        messageLength: message.length,
        blocked
      });
  
      return {
        outputInfo: {
          blocked,
          reason: blocked
            ? "Restricted instruction or credential request"
            : "Allowed"
        },
        tripwireTriggered: blocked
      };
    }
  };
  