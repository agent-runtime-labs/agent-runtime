# -*- mode: Python -*-
TARGET_ARCH = 'arm64'

ENV = 'local'
LOG_LEVEL=os.getenv('LOG_LEVEL', 'INFO')
AWS_ACCESS_KEY_ID=os.getenv('AWS_ACCESS_KEY_ID', '')
AWS_SECRET_ACCESS_KEY=os.getenv("AWS_SECRET_ACCESS_KEY", '')
AWS_REGION=os.getenv('AWS_REGION', 'us-east-1')

TALENT_KB_SSM_KB_ID_PATH=os.getenv('TALENT_KB_SSM_KB_ID_PATH')
ORCHESTRATOR_TASK_RESULTS_TABLE_NAME=os.getenv('ORCHESTRATOR_TASK_RESULTS_TABLE_NAME')


shared_config_map_data = {
    'LOG_LEVEL': LOG_LEVEL,
    'ENV': ENV,
    'AWS_ACCESS_KEY_ID': AWS_ACCESS_KEY_ID,
    'AWS_SECRET_ACCESS_KEY': AWS_SECRET_ACCESS_KEY,
    'TALENT_KB_SSM_KB_ID_PATH': TALENT_KB_SSM_KB_ID_PATH,
    'ORCHESTRATOR_TASK_RESULTS_TABLE_NAME': ORCHESTRATOR_TASK_RESULTS_TABLE_NAME,
    'OTEL_TRACES_EXPORTER': 'none',
    'OTEL_METRICS_EXPORTER': 'none',
    'OTEL_LOGS_EXPORTER': 'none',
}

load('ext://namespace', 'namespace_create', 'namespace_inject')

namespace = 'agent-runtime'
namespace_create(namespace)
load('ext://configmap', 'configmap_from_dict')

shared_configmap = configmap_from_dict('shared-config', inputs=shared_config_map_data)
k8s_yaml(namespace_inject(shared_configmap, namespace))

yaml = kustomize('./infra-as-code/k8s/tilt')
k8s_yaml(namespace_inject(yaml, namespace))


docker_build('orchestrator-agent', './backend',
    dockerfile='./backend/agents/orchestrator/Dockerfile',
    target='localdev',
    live_update=[
        sync('./backend/agents/orchestrator/src', '/workspace'),
    ], build_args={
        'TARGET_ARCH': TARGET_ARCH,
    })
k8s_resource('orchestrator-agent', port_forwards='8080:8080')
