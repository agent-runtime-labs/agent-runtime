import os

from agents.talent_kb_agent import create_talent_kb_tool
from prompt_loader import load_prompt
from strands import Agent, AgentSkills
from strands.models import BedrockModel

_SKILLS_DIR = os.path.join(os.path.dirname(__file__), "..", "config", "prompts", "skills")

orchestrator_model = BedrockModel(
        model_id="global.anthropic.claude-haiku-4-5-20251001-v1:0",
        temperature=0.2
    )


def orchestrator_multi_agent(query: str, auth_header: str = ""):
    """Create a fresh orchestrator agent per-request with auth_header baked into observability tools (mirrors swarm pattern)."""
    talent_kb_tool = create_talent_kb_tool(auth_header)
    skills_plugin = AgentSkills(skills=_SKILLS_DIR)
    agent = Agent(
        model=orchestrator_model,
        tools=[talent_kb_tool],
        system_prompt=load_prompt("orchestrator_multi_agent_prompt.txt"),
        plugins=[skills_plugin],
    )
    return agent(query)