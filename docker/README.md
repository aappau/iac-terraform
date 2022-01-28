## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 2.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_docker"></a> [docker](#provider\_docker) | 2.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [docker_container.jenkins](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) | resource |
| [docker_image.jenkins](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_volume.jenkins_home](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Value of the name for the Docker container | `string` | `"DevJenkinsContainer"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_ip"></a> [container\_ip](#output\_container\_ip) | IP of the Docker container |
| <a name="output_image_name"></a> [image\_name](#output\_image\_name) | Name of the Docker image |
