users = {
  "infra_manager_1" = {
    email               = "infra_manager_1@example.com"
    full_name           = "Infra Manager 1"
    roles               = ["infra-manager"]
    require_mfa         = true
    console_access      = true
    programmatic_access = false
    environments        = ["dev", "staging", "prod"]
  }

  "infra_member_2" = {
    email               = "infra_member_1@example.com"
    full_name           = "Infra member 2"
    roles               = ["infra-member"]
    require_mfa         = true
    console_access      = true
    programmatic_access = false
    environments        = ["dev", "staging", "prod"]
  }

  "dev1" = {
    email               = "dev1@example.com"
    full_name           = "Dev One"
    roles               = ["developer"]
    require_mfa         = true
    console_access      = true
    programmatic_access = true
    environments        = ["dev", "staging"]
  }
}

enforce_password_policy = true
enforce_mfa             = true
allowed_ip_ranges       = []
verify_cloudtrail       = true
