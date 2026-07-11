import os
import logging

from strands import Agent, tool
from strands.models import BedrockModel
from strands.tools.mcp import MCPClient
from talent_kb_mcp_utils import get_talent_kb_mcp_client

logger = logging.getLogger(__name__)

TALENT_KB_SYSTEM_PROMPT = """You are a Talent Knowledge Base specialist.
Use the talent_kb MCP tool to answer candidate search and talent profile questions.
Return concise answers with relevant skills, experience, certifications, availability, and citations when the tool provides them.
"""


def _create_talent_kb_agent(auth_header: str) -> Agent:
    """Builds the inner Agent that queries the Talent Knowledge Base MCP tool."""
    mcp_client = get_talent_kb_mcp_client(auth_header).start()
    return Agent(
        name="talent_kb_specialist",
        description="Specialist who analyzes talent knowledge base to provide insights and recommendations",
        model=BedrockModel(
            model_id="global.anthropic.claude-haiku-4-5-20251001-v1:0",
            temperature=0.2
        ),
        tools=[get_talent_kb_mcp_client(auth_header)],
        system_prompt=TALENT_KB_SYSTEM_PROMPT
    )


def create_talent_kb_tool(auth_header: str):
    """Factory that creates a @tool with auth_header baked in via closure (mirrors swarm pattern)."""
    if auth_header:
        logger.info(f"Talent KB tool created with auth_header: {auth_header[:20]}...")
    else:
        logger.warning("Talent KB tool created without auth_header — talent KB calls will fail")
    agent = _create_talent_kb_agent(auth_header)

    @tool
    def talent_kb_specialist_agent(query: str) -> str:
        """
        Delegate a talent knowledge base task to the specialist agent.
        Use this to analyze the talent knowledge base and provide insights and recommendations.

        Args:
            query: Natural language candidate search or talent profile question.

        Returns:
            Structured talent knowledge base answer with citations when available.
        """
        return str(agent(query))

    return talent_kb_specialist_agent
