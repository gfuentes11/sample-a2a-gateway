"""Rate limiting client for DynamoDB-based rate limiting."""

import os
from datetime import datetime, timezone, timedelta
from typing import Optional, Tuple
import boto3
from botocore.exceptions import ClientError


class RateLimitClient:
    """Client for checking and incrementing rate limit counters."""
    
    def __init__(self, table_name: str):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
    
    def check_rate_limit(self, user_id: str, agent_id: str, limit: int) -> Tuple[bool, Optional[int]]:
        """
        Check rate limit and increment counter atomically.
        
        Args:
            user_id: User identifier
            agent_id: Agent identifier
            limit: Maximum requests per minute
            
        Returns:
            Tuple of (allowed: bool, retry_after_seconds: Optional[int])
        """
        now = datetime.now(timezone.utc)
        minute_key = now.strftime('%Y-%m-%dT%H:%M')
        pk = f"{user_id}#{agent_id}#{minute_key}"
        
        # TTL: 2 minutes after this minute ends
        window_end = now.replace(second=0, microsecond=0) + timedelta(minutes=1)
        ttl = int((window_end + timedelta(minutes=1)).timestamp())
        
        try:
            self.table.update_item(
                Key={'pk': pk},
                UpdateExpression='SET #count = if_not_exists(#count, :zero) + :one, #ttl = :ttl',
                ConditionExpression='attribute_not_exists(#count) OR #count < :limit',
                ExpressionAttributeNames={
                    '#count': 'count',
                    '#ttl': 'ttl'
                },
                ExpressionAttributeValues={
                    ':zero': 0,
                    ':one': 1,
                    ':limit': limit,
                    ':ttl': ttl
                }
            )
            return True, None  # Allowed
            
        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                # Calculate retry-after
                retry_after = int((window_end - now).total_seconds())
                return False, max(1, retry_after)  # At least 1 second
            raise


def create_rate_limit_client() -> Optional[RateLimitClient]:
    """Create rate limit client from environment variables."""
    table_name = os.environ.get('RATE_LIMIT_TABLE')
    if not table_name:
        return None
    return RateLimitClient(table_name)
