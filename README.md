# agent-runtime

AWS Bedrock AgentCore Runtime based Agentic AI service built with Strands. Executes asynchronous agent workflows, orchestrates MCP tools, persists execution state in DynamoDB, and exposes REST APIs for job submission and result retrieval.

## Architecture

The runtime service provides asynchronous agent workflow execution with a multi-agent system architecture:

```mermaid
flowchart TD
    A[API Client]
    
    subgraph AWS["AWS Cloud"]
        AUTH[AWS Cognito\nJWT Authentication]
        B[Orchestrator Agent]
        C[Talent KB Agent]
        GW[AWS Bedrock\nAgentCore Gateway]
        E[Lambda\n Talent MCP Server]
        F[DynamoDB\nExecution State & Results]
    end
    
    A -->|Request with JWT Token| AUTH
    AUTH -->|Verify & Authorize| B
    B -->|Invoke| C
    C -->|Tool Invocations| GW
    GW -->|Route to| E
    B -->|Save Results| F

    classDef source fill:#E8F1FF,stroke:#2563EB,stroke-width:2px,color:#0F172A;
    classDef storage fill:#ECFDF5,stroke:#059669,stroke-width:2px,color:#064E3B;
    classDef compute fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#78350F;
    classDef ai fill:#F3E8FF,stroke:#7C3AED,stroke-width:2px,color:#4C1D95;
    classDef auth fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#7F1D1D;
    
    class A source;
    class E compute;
    class B,C,GW ai;
    class F storage;
    class AUTH auth;
```

### Key Components

- **AWS Cognito JWT Authentication**: Validates and authorizes API requests before allowing access to the orchestrator agent
- **Orchestrator Agent**: Top-level agent that coordinates the workflow and invokes specialized agents
- **Talent KB Agent**: Specialized agent that handles talent-related queries and tool invocations
- **AWS Bedrock AgentCore Gateway**: Routes MCP tool invocations from agents to external servers
- **Lambda Talent MCP Server**: AWS Lambda-based MCP server providing talent-related tools and capabilities
- **DynamoDB**: Persists execution state and workflow results

The service supports:
- Secure JWT-based authentication via AWS Cognito for all API requests
- Multi-agent workflow execution with orchestrator agent delegating to specialized agents
- Asynchronous agent workflow execution via authenticated Orchestrator Agent invocation
- MCP tool orchestration through AWS Bedrock AgentCore Gateway
- Integration with specialized agents for domain-specific tasks (e.g., Talent KB Agent)
- Persistent execution state and result storage in DynamoDB
