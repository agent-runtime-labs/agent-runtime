"""Shared logging configuration."""
import logging
import os
import sys
from datetime import datetime

_logging_configured = False


class ISO8601Formatter(logging.Formatter):
    """Custom formatter that outputs ISO8601 timestamps with milliseconds."""
    
    def format(self, record):
        # Create ISO8601 timestamp with milliseconds
        dt = datetime.fromtimestamp(record.created)
        timestamp = dt.strftime('%Y-%m-%dT%H:%M:%S') + f'.{int(record.msecs):03d}Z'
        
        # Build JSON log entry
        log_entry = {
            "timestamp": timestamp,
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name
        }
        
        import json
        return json.dumps(log_entry)


def configure_logging():
    """Configure structured JSON logging for the application."""
    global _logging_configured
    if _logging_configured:
        return

    log_level = os.getenv('LOG_LEVEL', 'INFO')
    formatter = ISO8601Formatter()
    root_logger = logging.getLogger()
    root_logger.setLevel(log_level)
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)
    _logging_configured = True


def get_logger(name: str) -> logging.Logger:
    configure_logging()
    return logging.getLogger(name)
