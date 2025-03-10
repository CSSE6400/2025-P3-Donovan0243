#!/bin/bash
#
# Check that the health endpoint is returning 200 using docker

# Build image
docker build -t todo .
error=$?
if [[ $error -ne 0 ]]; then
    echo "Failed to build docker image"
    exit 1
fi

# Run image
docker_container=$(docker run --rm -d -p 6400:6400 todo)
error=$?
if [[ $error -ne 0 ]]; then
    echo "Failed to run docker image"
    exit 1
fi

# Wait for the container to start
sleep 10

# Check that the health endpoint is returning 200
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:6400/api/v1/health")

if [[ "$response" != "200" ]]; then
    echo "Failed to get 200 from health endpoint"
    
    # 🛠️ **打印 Flask 容器日志，看看发生了什么错误**
    echo "===== Flask 容器日志 ====="
    docker logs ${docker_container}

    # **确保终止 GitHub Actions**
    exit 1
fi

# Kill docker container
docker stop ${docker_container}
