"""Shared logging configuration."""
import logging
import os
import sys

_logging_configured = False


def configure_logging():
    """Configure structured JSON logging for the application."""
    global _logging_configured
    if _logging_configured:
        return

    log_level = os.getenv('LOG_LEVEL', 'INFO')
    formatter = logging.Formatter(
        fmt='{"timestamp": "%(asctime)s", "level": "%(levelname)s", "message": "%(message)s", "logger": "%(name)s"}',
        datefmt='%Y-%m-%dT%H:%M:%S.%fZ'
    )
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
