
resource "gitea_repository" "this" {
  name          = var.name
  description   = var.description
  private       = var.private
  auto_init     = var.auto_init && var.readme_content == ""
  default_branch = var.default_branch

  has_issues       = var.enable_issues
  has_wiki         = var.enable_wiki
  has_pull_requests = var.enable_pulls

  allow_merge_commits = var.allow_merge_commits
  allow_rebase        = var.allow_rebase
  allow_squash_merge  = var.allow_squash_merge

  gitignore_template = var.gitignore_template
  license_template   = var.license

  archived = var.archived
}

resource "gitea_repository_file" "readme" {
  count = var.readme_content != "" ? 1 : 0

  repository = gitea_repository.this.name
  file       = "README.md"
  content    = base64encode(var.readme_content)
  branch     = var.default_branch

  author_name  = "Terraform"
  author_email = "terraform@automation"
  message      = "Initialize repository with README"
}
