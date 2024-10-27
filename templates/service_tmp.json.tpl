[
  {
    "name": "${prefix}-${env}-${app_name}",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${prefix}-${env}-${app_name}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "hostPort": ${app_port},
        "containerPort": ${app_port},
        "name": "${app_name}"
      }
      ${extra_ports}
    ],
    "ulimits": [
      {
        "softLimit": 50000,
        "hardLimit": 50000,
        "name": "nofile"
      }
    ],
    "environment":
    [
      { "name" : "AWS_XRAY_DAEMON_ADDRESS", "value" : "xray-daemon:2000" },
      { "name" : "ENV", "value" : "${env}" }
    ],
    "secrets": [${secrets}],
    "runtimePlatform": {
        "operatingSystemFamily": "LINUX"
    },
    "requiresCompatibilities": [ 
       "FARGATE" 
    ]
  }
  ${xray}
]