users = {
  "infra_manager_11" = {
    email               = "infra_manager_11@example.com"
    full_name           = "Infra Manager 1 1"
    roles               = ["infra-manager"]
    require_mfa         = true
    console_access      = true
    programmatic_access = false
    environments        = ["dev", "staging", "prod"]
  }

  "infra_member_22" = {
    email               = "infra_member_22@example.com"
    full_name           = "Infra member 2 2"
    roles               = ["infra-member"]
    require_mfa         = true
    console_access      = true
    programmatic_access = false
    environments        = ["dev", "staging", "prod"]
  }

  "dev11" = {
    email               = "dev11@example.com"
    full_name           = "Dev 1 1"
    roles               = ["developer"]
    require_mfa         = true
    console_access      = true
    programmatic_access = true
    environments        = ["dev", "staging"]
  }
  
  "security22" = {
    email               = "sec22@example.com"
    full_name           = "Security 2 2"
    roles               = ["developer"]
    require_mfa         = true
    console_access      = true
    programmatic_access = true
    environments        = ["staging", "prod"]
  }
}

