variable location {
  type = string
}
variable env_name {
  type = string
}
variable boot_diagnostics_storage {
  type = object(
    {
    storage_account_name = string
    resource_group_name  = string 
    }
  )
}