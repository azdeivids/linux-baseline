This will deploy linux virtual machine using a module from the azure devops repo. The image used will be
taken from existing azure compute gallery, which has been built using packer.

# What has been done?

1. Created linux image using the exisiting pipeline in Azure DevOps.
2. Deployed *v1* terraform code leveraging the existing terraform-module. The linux vm was built using the custom image from Azure compute gallery.
3. Setup boot diagnostics.
    * Boot diagnostics can help to identify issues with the custom image vm booting up, which has been built using packer.
    * Boot diagnostics are low cost.
    * Storage account is required to enable boot diagnostics. We used an existing storage account in UK south from log analitycs RG. 