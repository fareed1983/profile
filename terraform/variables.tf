variable "dockerhub_username" {
	type				= string
	description	= "Docker Hub username"
}

variable "dockerhub_password" {
	type 				= string
	description	= "Docker Hub password"
	sensitive		= true
}
