import os
import uuid
import json
import threading
from dataclasses import dataclass
from agents.orchestrator_multi_agent import orchestrator_multi_agent
from bedrock_agentcore.runtime import BedrockAgentCoreApp
from utils import get_logger
from dynamodb_utils import store_task_result


logger = get_logger(__name__)
app = BedrockAgentCoreApp(debug=os.getenv('AGENTCORE_DEBUG', 'false').lower() == 'true')


@dataclass
class TaskContext:
    task_id: str


def _extract_response_text(result) -> str:
    """Extract readable text from agent result."""
    message = result.message
    if not isinstance(message, dict):
        return "Agent completed but produced no readable content."
    
    content = message.get("content", [])
    if isinstance(content, list) and content and isinstance(content[0], dict):
        return content[0].get("text", "No text content found.")
    if isinstance(content, str):
        return content
    return "Agent completed but produced no readable content."


def run_orchestrator_agent(query: str, auth_header: str, task_ctx: TaskContext) -> None:
    """Run the orchestrator multi-agent and handle result storage."""
    table_name = os.getenv("ORCHESTRATOR_TASK_RESULTS_TABLE_NAME", "orchestrator-task-results").strip()
    region = os.getenv("AWS_REGION", "us-east-1").strip()

    logger.info(f"Starting orchestrator agent for task {task_ctx.task_id}")
    result = orchestrator_multi_agent(query, auth_header)
    logger.debug(json.dumps(vars(result), default=str, ensure_ascii=False))

    try:
        if result.stop_reason == "end_turn":
            response_text = _extract_response_text(result)
            logger.info(f"Extracted response text for task {task_ctx.task_id}: {response_text[:200]}...")
            store_task_result(
                table_name=table_name,
                task_id=task_ctx.task_id,
                status='completed',
                query=query,
                response=response_text,
                region=region
            )
        else:
            logger.warning(f"Task {task_ctx.task_id} ended with stop_reason: {result.stop_reason}")
            store_task_result(
                table_name=table_name,
                task_id=task_ctx.task_id,
                status='completed',
                query=query,
                response=f"Agent ended with stop_reason: {result.stop_reason}",
                region=region
            )
    except Exception as e:
        logger.error(f"Task {task_ctx.task_id} failed during result processing: {str(e)}")
        store_task_result(
            table_name=table_name,
            task_id=task_ctx.task_id,
            status='failed',
            query=query,
            error=str(e),
            region=region
        )
        raise
    finally:
        app.complete_async_task(task_ctx.task_id)
        logger.info(f"Task {task_ctx.task_id} marked as complete")


@app.entrypoint
async def invoke(payload=None, context=None):
    """Main entrypoint for the agent"""
    try:
        table_name = os.getenv("ORCHESTRATOR_TASK_RESULTS_TABLE_NAME", "orchestrator-task-results").strip()
        region = os.getenv("AWS_REGION", "us-east-1").strip()

        # Start new async task
        task_id = app.add_async_task("background_processing", {"batch": 100})

        # Get the query from payload
        default_query = """Identify talent clinicians based on their skills and qualifications."""
        query = payload.get("prompt", default_query) if payload else default_query

        # Extract authorization header
        request_headers = getattr(context, 'request_headers', {}) if context else {}
        auth_header = request_headers.get('Authorization', '')
        
        logger.info(f"Processing request with Authorization header: {auth_header[:20]}..." if auth_header else "No authorization header provided")

        # Store initial processing status
        store_task_result(
            table_name=table_name,
            task_id=str(task_id),
            status='processing',
            query=query,
            region=region
        )

        # Execute agent in background thread
        task_ctx = TaskContext(task_id=str(task_id))
        thread = threading.Thread(
            target=lambda: _run_with_error_handling(query, auth_header, task_ctx, task_id),
            daemon=True
        )
        thread.start()

        logger.info(f"Started async task {task_id}. Agent is now BUSY.")
        return {
            "status": "processing",
            "message": "Task started successfully. Processing in background.",
            "task_id": task_id,
            "query": query
        }

    except Exception as e:
        logger.error(f"Error in invoke: {str(e)}")
        return {"status": "error", "error": str(e)}


def _run_with_error_handling(query: str, auth_header: str, task_ctx: TaskContext, task_id) -> None:
    """Run orchestrator agent with error handling."""
    try:
        run_orchestrator_agent(query, auth_header, task_ctx)
    except Exception as e:
        logger.error(f"Error in thread execution: {str(e)}")
        app.complete_async_task(task_id)


if __name__ == "__main__":
    app.run()
