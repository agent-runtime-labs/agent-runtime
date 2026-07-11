import os
import boto3
from strands.tools.mcp import MCPClient
from mcp.client.streamable_http import streamablehttp_client
from utils import get_logger

logger = get_logger(__name__)


def get_talent_kb_mcp_client(auth_header: str) -> MCPClient:
    """
    Initialize and return an MCP client for the Talent KB AgentCore gateway.

    Args:
        auth_header: The Authorization header value (JWT token) for gateway authentication

    Returns:
        Configured MCPClient instance

    Raises:
        ValueError: If auth_header is empty or Talent KB gateway configuration is missing
        Exception: If gateway connection fails
    """
    if not auth_header:
        raise ValueError("Authorization header is required")

    env = os.environ.get('ENV', 'dev').lower()
    logger.info(f"Environment mode: ENV={env}")
    talent_kb_ssm_kb_id_path = os.getenv("TALENT_KB_SSM_KB_ID_PATH", "").strip()
    region = os.getenv("AWS_REGION", "us-east-1").strip()

    if not talent_kb_ssm_kb_id_path:
        raise ValueError("Talent KB SSM parameter path not found in configuration")

    logger.info(f"Fetching Talent KB gateway ID from SSM parameter: {talent_kb_ssm_kb_id_path}")

    try:
        ssm_client = boto3.client("ssm", region_name=region)
        kb_id_response = ssm_client.get_parameter(
            Name=talent_kb_ssm_kb_id_path,
            WithDecryption=True,
        )
        talent_kb_gateway_id = kb_id_response.get("Parameter", {}).get("Value", "").strip()
        if not talent_kb_gateway_id:
            raise ValueError(
                f"Talent KB gateway ID not found in SSM parameter: {talent_kb_ssm_kb_id_path}")

        logger.info(f"Initializing Talent KB MCP client for gateway: {talent_kb_gateway_id}")

        gateway_client = boto3.client(
            "bedrock-agentcore-control",
            region_name=region,
        )
        gateway_response = gateway_client.get_gateway(
            gatewayIdentifier=talent_kb_gateway_id)
        gateway_url = gateway_response.get('gatewayUrl')
        if not gateway_url:
            raise ValueError(
                f"Gateway URL not found for Talent KB gateway ID: {talent_kb_gateway_id}")
        logger.info(f"Talent KB Gateway URL retrieved: {gateway_url}")
        mcp_client = MCPClient(lambda: streamablehttp_client(
            url=gateway_url,
            headers={"Authorization": auth_header}
        ))
        return mcp_client
    except Exception as e:
        logger.error(f"Failed to create Talent KB MCP client: {str(e)}")
        raise Exception(f"Talent KB MCP client error: {str(e)}")
