ARG PYTHON_VERSION=3.12

# ============================================
# Base stage: Common dependencies and setup
# ============================================
FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-slim AS base

WORKDIR /workspace

# Install dependencies from pyproject.toml
RUN pip install --no-cache-dir \
    strands-agents>=1.20.0 \
    boto3>=1.40.0 \
    botocore>=1.40.0 \
    bedrock-agentcore>=1.1.1 \
    PyJWT>=2.10.0 \
    requests>=2.32.0 \
    tenacity>=9.0.0 \
    aws-opentelemetry-distro>=0.10.1

# Create non-root user
RUN useradd -m -u 1000 bedrock_agentcore

# ============================================
# Build stage: Common application setup
# ============================================
FROM base AS build

# Copy application code (shared between localdev and dist)
COPY --chown=bedrock_agentcore:bedrock_agentcore agents/orchestrator/src/ .
COPY --chown=bedrock_agentcore:bedrock_agentcore shared/utils/ /workspace/utils/

USER bedrock_agentcore

WORKDIR /workspace

# ============================================
# Localdev stage: For local development with hot reloading
# ============================================
FROM build AS localdev

USER root
# Install development dependencies for hot reloading
RUN pip install --no-cache-dir watchdog

USER bedrock_agentcore

# Note: Application code will be mounted as a volume by Tilt for hot reloading
# Expected mount point: /workspace

CMD ["opentelemetry-instrument", "python", "-m", "agent"]

# ============================================
# Dist stage: Production build with embedded code
# ============================================
FROM build AS dist

EXPOSE 8080
EXPOSE 8000

CMD ["opentelemetry-instrument", "python", "-m", "agent"]
