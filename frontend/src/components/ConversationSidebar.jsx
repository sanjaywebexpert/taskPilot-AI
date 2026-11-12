
import {
    Bot,
    Plus,
    MessageSquare
  } from "lucide-react";
  
  function ConversationSidebar({
    conversations,
    activeConversationId,
    onSelect,
    onNewChat,
    busy
  }) {
    return (
      <aside className="conversation-sidebar">
        <div className="sidebar-brand">
          <Bot size={24} />
          <h2>TaskPilot AI</h2>
        </div>
  
        <button
          type="button"
          className="new-chat-btn"
          onClick={onNewChat}
          disabled={busy}
        >
          <Plus size={18} />
          New Chat
        </button>
  
        <div className="sidebar-heading">
          Recent Conversations
        </div>
  
        <div className="conversation-list">
          {conversations.length === 0 && (
            <p className="no-conversations">
              No previous conversations
            </p>
          )}
  
          {conversations.map(conversation => (
            <button
              type="button"
              key={conversation.id}
              disabled={busy}
              className={
                "conversation-item " +
                (activeConversationId === conversation.id
                  ? "active"
                  : "")
              }
              onClick={() => onSelect(conversation.id)}
              title={conversation.title}
            >
              <MessageSquare size={16} />
  
              <span className="conversation-title">
                {conversation.title}
              </span>
            </button>
          ))}
        </div>
      </aside>
    );
  }
  
  export default ConversationSidebar;
  