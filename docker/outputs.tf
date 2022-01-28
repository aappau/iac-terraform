output "container_ip" {
  description = "IP of the Docker container"
  value       = docker_container.jenkins.ip_address
}

output "image_name" {
  description = "Name of the Docker image"
  value       = docker_image.jenkins.name
}