
output "name" {
  description = "Repository name"
  value       = gitea_repository.this.name
}

output "full_name" {
  description = "Repository full name (owner/repo)"
  value       = gitea_repository.this.full_name
}

output "html_url" {
  description = "Repository web URL"
  value       = gitea_repository.this.html_url
}

output "clone_url" {
  description = "Repository clone URL (HTTP)"
  value       = gitea_repository.this.clone_url
}

output "ssh_url" {
  description = "Repository SSH URL"
  value       = gitea_repository.this.ssh_url
}

output "default_branch" {
  description = "Default branch name"
  value       = gitea_repository.this.default_branch
}

output "private" {
  description = "Whether the repository is private"
  value       = gitea_repository.this.private
}

output "id" {
  description = "Repository ID"
  value       = gitea_repository.this.id
}
