terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_volume" "jenkins_home" {
  name = "jenkins_home"
}

resource "docker_image" "jenkins" {
  name         = "jenkins/jenkins:latest"
  keep_locally = false
}

resource "docker_container" "jenkins" {
  image = docker_image.jenkins.latest
  name  = var.container_name

  ports {
    internal = 8080
    external = 8080
  }

  volumes {
    container_path  = "/var/jenkins_hone"
    host_path       = "/var/lib/docker/volumes"
    volume_name     = "jenkins_home"
  }
}