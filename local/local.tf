resource "local_file" "foo" {
  content  = var.content
  filename = "${path.module}/foo.bar"
}

# Pega algo que já existe
data "local_file" "foo" {
  filename = "${path.module}/foo.bar"
}

output "data-source" {
  value       = data.local_file.foo.content
  sensitive   = false
  description = "output content of the data source"
  depends_on  = [data.local_file.foo]
}

variable "content" {
  type = string
}

output "id_archive" {
  value       = resource.local_file.foo.id
  sensitive   = false
  description = "output id of the archive"
  depends_on  = [local_file.foo]
}

output "content" {
  value       = resource.local_file.foo.content
}