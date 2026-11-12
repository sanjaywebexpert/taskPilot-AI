
import { useState, useRef, useEffect } from "react";
import { Bot, Send, User } from "lucide-react";
import api from "../services/api";
import "./Chat.css";
import ConversationSidebar from "./ConversationSidebar";

function Chat() {
  const [messages, setMessages] = useState([
    {
      role: "assistant",
      content: "Hello! I'm TaskPilot AI. How can I help manage your tasks?"
    }
  ]);

  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [conversationId, setConversationId] = useState(() => {
    return localStorage.getItem("taskpilot_conversation_id");
  });

  const bottomRef = useRef(null);
  const sendingRef = useRef(false);

  const [historyLoading, setHistoryLoading] = useState(
    Boolean(localStorage.getItem("taskpilot_conversation_id"))
  );

  const [conversations, setConversations] = useState([]);
  const [sidebarError, setSidebarError] = useState("");
  const historyRequestRef = useRef(0);


  const loadConversations = async () => {
    try {
      const response = await api.get("/conversations");
  
      console.log("Conversation list API:", response.data);
  
      if (response.data.success) {
        setConversations(response.data.conversations || []);
        setSidebarError("");
      }
  
    } catch (error) {
      console.error("Conversation list failed:", error);
  
      setSidebarError("Unable to load conversations");
    }
  };
  

  useEffect(() => {
    let cancelled = false;
  
    const fetchInitialConversations = async () => {
      try {
        const response = await api.get("/conversations");
  
        if (cancelled) return;
  
        if (response.data.success) {
          setConversations(response.data.conversations || []);
          setSidebarError("");
        }
      } catch (error) {
        if (cancelled) return;
  
        console.error("Sidebar loading failed:", error);
        setSidebarError("Unable to load conversations");
      }
    };
  
    fetchInitialConversations();
  
    return () => {
      cancelled = true;
    };
  }, []);
  



const selectConversation = async (id) => {
  if (loading || sendingRef.current || historyLoading) {
    return;
  }

  if (id === conversationId) {
    return;
  }

  const requestId = ++historyRequestRef.current;

  setHistoryLoading(true);

  try {
    const response = await api.get(
      `/conversations/${id}/messages`
    );

    // Ignore an outdated response.
    if (requestId !== historyRequestRef.current) {
      return;
    }

    if (response.data.success) {
      setConversationId(id);

      setMessages(
        response.data.messages.length
          ? response.data.messages
          : [{
              role: "assistant",
              content: "Hello! How can I help?"
            }]
      );

      localStorage.setItem(
        "taskpilot_conversation_id",
        id
      );
    }

  } catch (error) {
    console.error("Switch conversation failed:", error);

    // Keep the current conversation if loading fails.
    alert("Unable to load the selected conversation.");

  } finally {
    if (requestId === historyRequestRef.current) {
      setHistoryLoading(false);
    }
  }
};


const startNewChat = () => {
  if (loading || sendingRef.current || historyLoading) {
    return;
  }

  historyRequestRef.current += 1;

  setConversationId(null);

  localStorage.removeItem(
    "taskpilot_conversation_id"
  );

  setMessages([
    {
      role: "assistant",
      content:
        "Hello! I'm TaskPilot AI. How can I help manage your tasks?"
    }
  ]);

  setInput("");
};


  useEffect(() => {
    bottomRef.current?.scrollIntoView({
      behavior: "smooth"
    });
  }, [messages, loading]);

  
useEffect(() => {
    const savedId = localStorage.getItem(
      "taskpilot_conversation_id"
    );
  
    if (!savedId) {
      setHistoryLoading(false);
      return;
    }
  
    let cancelled = false;
  
    const loadHistory = async () => {
      try {
        const response = await api.get(
          `/conversations/${savedId}/messages`
        );
  
        if (cancelled) return;
  
        if (response.data.success) {
          setConversationId(savedId);
  
          setMessages(
            response.data.messages.length
              ? response.data.messages
              : [{
                  role: "assistant",
                  content: "Hello! I'm TaskPilot AI. How can I help?"
                }]
          );
        }
  
      } catch (error) {
        if (cancelled) return;
  
        console.error("History loading failed:", error);
  
        if (error.response?.status === 404 ||
            error.response?.status === 400) {
          localStorage.removeItem(
            "taskpilot_conversation_id"
          );
          setConversationId(null);
        } else {
          setMessages([{
            role: "error",
            content: "Unable to load conversation history. Please refresh to retry."
          }]);
        }
  
      } finally {
        if (!cancelled) {
          setHistoryLoading(false);
        }
      }
    };
  
    loadHistory();
  
    return () => {
      cancelled = true;
    };
  }, []);
  

  const sendMessage = async () => {
    const message = input.trim();

    if (!message || sendingRef.current || historyLoading) return;

    sendingRef.current = true;
    setLoading(true);
    setInput("");

    setMessages(previous => [
      ...previous,
      { role: "user", content: message }
    ]);

    try {
      const response = await api.post(
        "/chat",
        {
          message,
          ...(conversationId ? { conversationId } : {})
        },
        {
          headers: {
            // Automatically generated for this new submission.
            "Idempotency-Key": crypto.randomUUID()
          }
        }
      );

      if (!response.data.success) {
        throw new Error("Agent request failed");
      }

      setConversationId(response.data.conversationId);
      localStorage.setItem(
        "taskpilot_conversation_id",
        response.data.conversationId
      );
      await loadConversations();
      setMessages(previous => [
        ...previous,
        {
          role: "assistant",
          content: response.data.response
        }
      ]);

    } catch (error) {
      console.error("Chat API error:", error);

      const errorMessage =
        error.response?.data?.message ||
        "Something went wrong. Please try again.";

      setMessages(previous => [
        ...previous,
        {
          role: "error",
          content: errorMessage
        }
      ]);

    } finally {
      sendingRef.current = false;
      setLoading(false);
    }
  };

  const handleKeyDown = (event) => {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      sendMessage();
    }
  };

  return (

    <div className="app-layout">
    <ConversationSidebar
      conversations={conversations}
      activeConversationId={conversationId}
      onSelect={selectConversation}
      onNewChat={startNewChat}
      busy={loading || historyLoading}
    />
    <div className="chat-page">
      <header className="chat-header">
        <div className="brand-icon">
          <Bot size={26} />
        </div>

        <div>
          <h1>TaskPilot AI</h1>
          <p>Your intelligent task management assistant</p>
        </div>
      </header>

      <div className="chat-messages">
        {messages.map((message, index) => (
          <div
            key={index}
            className={`chat-message ${message.role}`}
          >
            <div className="message-avatar">
              {message.role === "user"
                ? <User size={18} />
                : <Bot size={18} />}
            </div>

            <div className="message-content">
              {message.content}
            </div>
          </div>
        ))}

        {loading && (
          <div className="chat-message assistant">
            <div className="message-avatar">
              <Bot size={18} />
            </div>
            <div className="message-content">
              TaskPilot AI is thinking...
            </div>
          </div>
        )}

        <div ref={bottomRef} />
      </div>

      {historyLoading && (
        <p className="history-loading">
          Loading previous conversation...
        </p>
      )}

      <div className="chat-input-container">
        <textarea
          value={input}
          onChange={(event) => setInput(event.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Ask TaskPilot AI..."
          disabled={loading || historyLoading}
          maxLength={2000}
          rows={2}
        />
       
       
<button
  type="button"
  onClick={sendMessage}
  disabled={historyLoading || loading || !input.trim()}
  aria-label="Send message"
>
  <Send size={20} />
</button>

      </div>

      <div className="chat-footer">
        Enter to send · Shift + Enter for new line
      </div>
    </div>
    </div>

  );
}

export default Chat;
