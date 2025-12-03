
variable "name" {
  description = "Repository name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Repository name must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "description" {
  description = "Repository description"
  type        = string
  default     = ""
}

variable "private" {
  description = "Whether the repository is private"
  type        = bool
  default     = false
}

variable "auto_init" {
  description = "Auto-initialize repository with README"
  type        = bool
  default     = true
}

variable "default_branch" {
  description = "Default branch name"
  type        = string
  default     = "main"

  validation {
    condition     = contains(["main", "master"], var.default_branch)
    error_message = "Default branch must be 'main' or 'master'"
  }
}

variable "gitignore_template" {
  description = "Gitignore template to use (e.g., 'Go', 'Python', 'Node')"
  type        = string
  default     = ""
}

variable "license" {
  description = "License template to use (e.g., 'MIT', 'Apache-2.0', 'GPL-3.0')"
  type        = string
  default     = ""
}

# ============================================
# Organization Standards
# ============================================

variable "enable_issues" {
  description = "Enable issue tracker"
  type        = bool
  default     = true
}

variable "enable_wiki" {
  description = "Enable wiki"
  type        = bool
  default     = false
}

variable "enable_pulls" {
  description = "Enable pull requests"
  type        = bool
  default     = true
}

variable "allow_merge_commits" {
  description = "Allow merge commits"
  type        = bool
  default     = true
}

variable "allow_rebase" {
  description = "Allow rebase merging"
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "Allow squash merging"
  type        = bool
  default     = true
}

# ============================================
# Additional Settings
# ============================================

variable "readme_content" {
  description = "Custom README.md content (overrides auto_init default)"
  type        = string
  default     = ""
}

variable "topics" {
  description = "Repository topics/tags"
  type        = list(string)
  default     = []
}

variable "archived" {
  description = "Whether the repository is archived"
  type        = bool
  default     = false
}
