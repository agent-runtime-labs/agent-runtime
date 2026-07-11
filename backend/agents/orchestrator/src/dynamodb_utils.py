import boto3
from datetime import datetime
from typing import Optional
from utils import get_logger

logger = get_logger(__name__)


def store_task_result(
    table_name: str,
    task_id: str,
    status: str,
    query: str,
    region: str,
    response: Optional[str] = None,
    error: Optional[str] = None
) -> None:
    """
    Store task execution result in DynamoDB.
    
    Args:
        table_name: DynamoDB table name
        task_id: Unique task identifier
        status: Task status (processing, completed, failed)
        query: Original query/prompt
        region: AWS region
        response: Task response (optional)
        error: Error message if task failed (optional)
    """
    try:
        dynamodb = boto3.resource('dynamodb', region_name=region)
        table = dynamodb.Table(table_name)
        
        item = {
            'task_id': task_id,
            'status': status,
            'query': query,
            'timestamp': datetime.utcnow().isoformat(),
        }
        
        if response:
            item['response'] = response
        
        if error:
            item['error'] = error
        
        table.put_item(Item=item)
        logger.info(f"Stored task result for {task_id} with status {status}")
        
    except Exception as e:
        logger.error(f"Failed to store task result for {task_id}: {str(e)}")
        raise
