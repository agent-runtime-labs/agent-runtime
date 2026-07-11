"""Utility for loading agent system prompts from text files."""
import os
from utils import get_logger

logger = get_logger(__name__)

_PROMPTS_DIR = os.path.join(os.path.dirname(__file__), "config", "prompts")


def load_prompt(filename: str) -> str:
    """
    Load a system prompt from a text file in config/prompts/.

    Args:
        filename: Name of the prompt file

    Returns:
        str: Contents of the prompt file

    Raises:
        FileNotFoundError: If the prompt file does not exist
    """
    prompt_path = os.path.join(_PROMPTS_DIR, filename)
    logger.debug("Loading prompt from %s", prompt_path)
    with open(prompt_path, "r", encoding="utf-8") as f:
        return f.read()


