terraform {
	required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0"
    }
	}
}

provider "docker" {
  registry_auth {
    address  = "https://registry-1.docker.io"
    username  = var.dockerhub_username
    password  = var.dockerhub_password
  }
}

resource "null_resource" "convert_markdown" {
  provisioner "local-exec" {
    command = "bash ../scripts/convert.sh"
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "docker_image" "profile_site" {
  name = "registry-1.docker.io/fareed83/profile-site:latest"
  build {
    context     = "../"
    dockerfile  = "Dockerfile"
  }
}

resource "docker_registry_image" "profile_site_push" {
  name          = docker_image.profile_site.name
  keep_remotely = true
}
