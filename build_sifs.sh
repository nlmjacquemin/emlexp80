#!/bin/bash
set -e

# Create output folder for .sif files
mkdir -p images

echo "🔧 Building Docker images and converting to Apptainer (.sif)..."

for folder in dockerfiles/*/; do
    tool_name=$(basename "$folder")
    image_tag="emlexp80-${tool_name}:latest"
    sif_path="images/${tool_name}.sif"
    
    echo "🚧 Building Docker image for $tool_name..."
    docker build -t "$image_tag" "$folder"
    
    echo "📦 Converting Docker image to Apptainer: $sif_path"
    apptainer build "$sif_path" "docker-daemon://$image_tag"
done

echo "✅ All images built and converted to SIF."