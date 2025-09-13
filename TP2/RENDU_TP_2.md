# TP1 : Azure first steps 

_Réutilisattion du dossier "terraform" du TP1 avec les différents fichiers_

## 1. Network Security Group

Pour ajouter le NSG au déploiment, il faut tout d'abord ajouter la variable ```public_ip_address``` dans le fichier ```variables.tf``` et lui attribuer notre valeur dans ```terraform.tfvars``` : 

Voici ce qui est ajouter dans le fichier ```variables.tf``` : 
  ```
  variable "public_ip_address" {
    type        = string
    description = "Public IP address to assign to the VM"
  }
  ```

Maintenant, nous créons donc le fichier ```network.tf``` afin d'y mettre la configuration du NSG. Voici le code complet que nous ajoutons dans ce fichier : 
  ```
  resource "azurerm_network_security_group" "main" {
    name                = "network-security-group"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    security_rule {
      name                       = "Allow-SSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = var.public_ip_address
      destination_address_prefix = "*"
    }

    tags = {
      environment = "Production"
    }
  }

  resource "azurerm_network_interface_security_group_association" "main" {
    network_interface_id      = azurerm_network_interface.main.id
    network_security_group_id = azurerm_network_security_group.main.id
  }
  ```

Cette configuration va donc permettre de n’autoriser que les connexions SSH entrantes provenant de mon adresse IP publique.

La resource ```azurerm_network_interface_security_group_association```, qui permet de faire le lien entre la carte réseau de la VM et le NSG, peut soit être placé dans le fichier ```main.tf```, ou dans le fichier ```network.tf```. J'ai décidé de le placer en fin du fichier ```network.tf```.

**Preuves que cela a bien fonctionné :**
- Sortie du ```terraform apply``` (Lors de la sortie de la commande, les valeurs de variables du fichier ```terraform.tfvars``` sont affichés en clair. Pour garder ces valeurs inconnues, ces dernières sont remplacées par "PRIVE") : 
  ```
  $ terraform apply

  Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    + create

  Terraform will perform the following actions:

    # azurerm_linux_virtual_machine.main will be created
    + resource "azurerm_linux_virtual_machine" "main" {
        + admin_username                                         = PRIVE
        + allow_extension_operations                             = (known after apply)
        + bypass_platform_safety_checks_on_user_schedule_enabled = false
        + computer_name                                          = (known after apply)
        + disable_password_authentication                        = (known after apply)
        + disk_controller_type                                   = (known after apply)
        + extensions_time_budget                                 = "PT1H30M"
        + id                                                     = (known after apply)
        + location                                               = PRIVE
        + max_bid_price                                          = -1
        + name                                                   = "VM-CREATION-TERRAFORM"
        + network_interface_ids                                  = (known after apply)
        + os_managed_disk_id                                     = (known after apply)
        + patch_assessment_mode                                  = (known after apply)
        + patch_mode                                             = (known after apply)
        + platform_fault_domain                                  = -1
        + priority                                               = "Regular"
        + private_ip_address                                     = (known after apply)
        + private_ip_addresses                                   = (known after apply)
        + provision_vm_agent                                     = (known after apply)
        + public_ip_address                                      = (known after apply)
        + public_ip_addresses                                    = (known after apply)
        + resource_group_name                                    = PRIVE
        + size                                                   = "Standard_B1s"
        + virtual_machine_id                                     = (known after apply)
        + vm_agent_platform_updates_enabled                      = (known after apply)

        + admin_ssh_key {
            + public_key = PRIVE
            + username   = PRIVE
          }

        + os_disk {
            + caching                   = "ReadWrite"
            + disk_size_gb              = (known after apply)
            + id                        = (known after apply)
            + name                      = "vm-os-disk"
            + storage_account_type      = "Standard_LRS"
            + write_accelerator_enabled = false
          }

        + source_image_reference {
            + offer     = "0001-com-ubuntu-server-focal"
            + publisher = "Canonical"
            + sku       = "20_04-lts"
            + version   = "latest"
          }

        + termination_notification (known after apply)
      }

    # azurerm_network_interface.main will be created
    + resource "azurerm_network_interface" "main" {
        + accelerated_networking_enabled = false
        + applied_dns_servers            = (known after apply)
        + id                             = (known after apply)
        + internal_domain_name_suffix    = (known after apply)
        + ip_forwarding_enabled          = false
        + location                       = PRIVE
        + mac_address                    = (known after apply)
        + name                           = "vm-nic"
        + private_ip_address             = (known after apply)
        + private_ip_addresses           = (known after apply)
        + resource_group_name            = PRIVE
        + virtual_machine_id             = (known after apply)

        + ip_configuration {
            + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
            + name                                               = "internal"
            + primary                                            = (known after apply)
            + private_ip_address                                 = (known after apply)
            + private_ip_address_allocation                      = "Dynamic"
            + private_ip_address_version                         = "IPv4"
            + public_ip_address_id                               = (known after apply)
            + subnet_id                                          = (known after apply)
          }
      }

    # azurerm_network_interface_security_group_association.main will be created
    + resource "azurerm_network_interface_security_group_association" "main" {
        + id                        = (known after apply)
        + network_interface_id      = (known after apply)
        + network_security_group_id = (known after apply)
      }

    # azurerm_network_security_group.main will be created
    + resource "azurerm_network_security_group" "main" {
        + id                  = (known after apply)
        + location            = PRIVE
        + name                = "network-security-group"
        + resource_group_name = PRIVE
        + security_rule       = [
            + {
                + access                                     = "Allow"
                + destination_address_prefix                 = "*"
                + destination_address_prefixes               = []
                + destination_application_security_group_ids = []
                + destination_port_range                     = "22"
                + destination_port_ranges                    = []
                + direction                                  = "Inbound"
                + name                                       = "Allow-SSH"
                + priority                                   = 1001
                + protocol                                   = "Tcp"
                + source_address_prefix                      = PRIVE
                + source_address_prefixes                    = []
                + source_application_security_group_ids      = []
                + source_port_range                          = "*"
                + source_port_ranges                         = []
                  # (1 unchanged attribute hidden)
              },
          ]
        + tags                = {
            + "environment" = "Production"
          }
      }

    # azurerm_public_ip.main will be created
    + resource "azurerm_public_ip" "main" {
        + allocation_method       = "Static"
        + ddos_protection_mode    = "VirtualNetworkInherited"
        + fqdn                    = (known after apply)
        + id                      = (known after apply)
        + idle_timeout_in_minutes = 4
        + ip_address              = (known after apply)
        + ip_version              = "IPv4"
        + location                = PRIVE
        + name                    = "vm-ip"
        + resource_group_name     = PRIVE
        + sku                     = "Standard"
        + sku_tier                = "Regional"
      }

    # azurerm_resource_group.main will be created
    + resource "azurerm_resource_group" "main" {
        + id       = (known after apply)
        + location = PRIVE
        + name     = PRIVE
      }

    # azurerm_subnet.main will be created
    + resource "azurerm_subnet" "main" {
        + address_prefixes                              = [
            + "10.0.1.0/24",
          ]
        + default_outbound_access_enabled               = true
        + id                                            = (known after apply)
        + name                                          = "vm-subnet"
        + private_endpoint_network_policies             = "Disabled"
        + private_link_service_network_policies_enabled = true
        + resource_group_name                           = PRIVE
        + virtual_network_name                          = "vm-vnet"
      }

    # azurerm_virtual_network.main will be created
    + resource "azurerm_virtual_network" "main" {
        + address_space                  = [
            + "10.0.0.0/16",
          ]
        + dns_servers                    = (known after apply)
        + guid                           = (known after apply)
        + id                             = (known after apply)
        + location                       = PRIVE
        + name                           = "vm-vnet"
        + private_endpoint_vnet_policies = "Disabled"
        + resource_group_name            = PRIVE
        + subnet                         = (known after apply)
      }

  Plan: 8 to add, 0 to change, 0 to destroy.

  Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

  azurerm_resource_group.main: Creating...
  azurerm_resource_group.main: Creation complete after 9s [id=/subscriptions/PRIVE/resourceGroups/PRIVE]
  azurerm_virtual_network.main: Creating...
  azurerm_public_ip.main: Creating...
  azurerm_network_security_group.main: Creating...
  azurerm_network_security_group.main: Creation complete after 2s [id=/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Network/networkSecurityGroups/network-security-group]
  azurerm_public_ip.main: Creation complete after 2s [id=/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Network/publicIPAddresses/vm-ip]
  azurerm_virtual_network.main: Creation complete after 5s [id=/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Network/virtualNetworks/vm-vnet]
  azurerm_subnet.main: Creating...
  azurerm_subnet.main: Creation complete after 4s [id=/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Network/virtualNetworks/vm-vnet/subnets/vm-subnet]
  azurerm_network_interface.main: Creating...
  azurerm_network_interface.main: Still creating... [00m10s elapsed]
  azurerm_network_interface.main: Creation complete after 12s [id=/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Network/networkInterfaces/vm-nic]
  azurerm_network_interface_security_group_association.main: Creating...
  azurerm_linux_virtual_machine.main: Creating...
  azurerm_network_interface_security_group_association.main: Still creating... [00m10s elapsed]
  azurerm_linux_virtual_machine.main: Still creating... [00m10s elapsed]
  azurerm_network_interface_security_group_association.main: Creation complete after 11s [id=/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Network/networkInterfaces/vm-nic|/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Network/networkSecurityGroups/network-security-group] 
  azurerm_linux_virtual_machine.main: Still creating... [00m20s elapsed]
  azurerm_linux_virtual_machine.main: Still creating... [00m30s elapsed]
  azurerm_linux_virtual_machine.main: Still creating... [00m40s elapsed]
  azurerm_linux_virtual_machine.main: Creation complete after 48s [id=/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Compute/virtualMachines/VM-CREATION-TERRAFORM]

  Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
  ```

- Commande ```az``` pour obtenir toutes les infos liées à la VM : 
  ```
  PS C:\Users\Florian Andries> az vm show --resource-group PRIVE --name VM-CREATION-TERRAFORM --output json
  {
    "additionalCapabilities": null,
    "applicationProfile": null,
    "availabilitySet": null,
    "billingProfile": null,
    "capacityReservation": null,
    "diagnosticsProfile": {
      "bootDiagnostics": {
        "enabled": false,
        "storageUri": null
      }
    },
    "etag": "\"1\"",
    "evictionPolicy": null,
    "extendedLocation": null,
    "extensionsTimeBudget": "PT1H30M",
    "hardwareProfile": {
      "vmSize": "Standard_B1s",
      "vmSizeProperties": null
    },
    "host": null,
    "hostGroup": null,
    "id": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Compute/virtualMachines/VM-CREATION-TERRAFORM",
    "identity": null,
    "instanceView": null,
    "licenseType": null,
    "location": PRIVE,
    "managedBy": null,
    "name": "VM-CREATION-TERRAFORM",
    "networkProfile": {
      "networkApiVersion": null,
      "networkInterfaceConfigurations": null,
      "networkInterfaces": [
        {
          "deleteOption": null,
          "id": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Network/networkInterfaces/vm-nic",
          "primary": true,
          "resourceGroup": PRIVE
        }
      ]
    },
    "osProfile": {
      "adminPassword": null,
      "adminUsername": PRIVE,
      "allowExtensionOperations": true,
      "computerName": "VM-CREATION-TERRAFORM",
      "customData": null,
      "linuxConfiguration": {
        "disablePasswordAuthentication": true,
        "enableVmAgentPlatformUpdates": null,
        "patchSettings": {
          "assessmentMode": "ImageDefault",
          "automaticByPlatformSettings": null,
          "patchMode": "ImageDefault"
        },
        "provisionVmAgent": true,
        "ssh": {
          "publicKeys": [
            {
              "keyData": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxzDiSPVLj4dMnGr0/8jZYMpDyI30dvq1+hNVMecsj1 PRIVE\r\n",
              "path": PRIVE
            }
          ]
        }
      },
      "requireGuestProvisionSignal": true,
      "secrets": [],
      "windowsConfiguration": null
    },
    "placement": null,
    "plan": null,
    "platformFaultDomain": null,
    "priority": "Regular",
    "provisioningState": "Succeeded",
    "proximityPlacementGroup": null,
    "resourceGroup": PRIVE,
    "resources": null,
    "scheduledEventsPolicy": null,
    "scheduledEventsProfile": null,
    "securityProfile": null,
    "storageProfile": {
      "alignRegionalDisksToVmZone": null,
      "dataDisks": [],
      "diskControllerType": null,
      "imageReference": {
        "communityGalleryImageId": null,
        "exactVersion": "20.04.202505200",
        "id": null,
        "offer": "0001-com-ubuntu-server-focal",
        "publisher": "Canonical",
        "sharedGalleryImageId": null,
        "sku": "20_04-lts",
        "version": "latest"
      },
      "osDisk": {
        "caching": "ReadWrite",
        "createOption": "FromImage",
        "deleteOption": "Detach",
        "diffDiskSettings": null,
        "diskSizeGb": 30,
        "encryptionSettings": null,
        "image": null,
        "managedDisk": {
          "diskEncryptionSet": null,
          "id": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Compute/disks/vm-os-disk",
          "resourceGroup": PRIVE,
          "securityProfile": null,
          "storageAccountType": "Standard_LRS"
        },
        "name": "vm-os-disk",
        "osType": "Linux",
        "vhd": null,
        "writeAcceleratorEnabled": false
      }
    },
    "tags": {},
    "timeCreated": "2025-09-07T08:52:24.470261+00:00",
    "type": "Microsoft.Compute/virtualMachines",
    "userData": null,
    "virtualMachineScaleSet": null,
    "vmId": "61b0aff5-d3e5-4049-87b5-575d3e3d5ef0",
    "zones": null
  }
  ```

- Commande ```ssh``` fonctionnelle, sans mot de passe : 
  ```
  PS C:\Users\Florian Andries> ssh PRIVE@4.251.105.150
  The authenticity of host '4.251.105.150 (4.251.105.150)' can't be established.
  ED25519 key fingerprint is SHA256:hY00+Z1JVzGlYQYjJi00o8wi8zEHfr7qJ7aIMg+Ed+0.
  This key is not known by any other names.
  Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
  Warning: Permanently added '4.251.105.150' (ED25519) to the list of known hosts.
  Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1089-azure x86_64)

  * Documentation:  https://help.ubuntu.com
  * Management:     https://landscape.canonical.com
  * Support:        https://ubuntu.com/pro

  System information as of Sun Sep  7 13:35:31 UTC 2025

    System load:  0.0               Processes:             110
    Usage of /:   5.4% of 28.89GB   Users logged in:       0
    Memory usage: 29%               IPv4 address for eth0: 10.0.1.4
    Swap usage:   0%

  * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
    just raised the bar for easy, resilient and secure K8s cluster deployment.

    https://ubuntu.com/engage/secure-kubernetes-at-the-edge

  Expanded Security Maintenance for Applications is not enabled.

  0 updates can be applied immediately.

  Enable ESM Apps to receive additional future security updates.
  See https://ubuntu.com/esm or run: sudo pro status


  The list of available updates is more than a week old.
  To check for new updates run: sudo apt update


  The programs included with the Ubuntu system are free software;
  the exact distribution terms for each program are described in the
  individual files in /usr/share/doc/*/copyright.

  Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
  applicable law.

  To run a command as administrator (user "root"), use "sudo <command>".
  See "man sudo_root" for details.

  PRIVE@VM-CREATION-TERRAFORM:~$
  ```

- Changement de port : 
  - Modification du port d'écoute du serveur OpenSSH sur la VM pour le port 2222/tcp :
    ```
    sudo nano /etc/ssh/sshd_config
    ```
    Remplacer la valeur suivante : 
    ```
    #Port 22
    ```
    Par :
    ```
    Port 2222
    ```

  - Preuve que le serveur OpenSSH écoute sur ce nouveau port ()
    ```
    PRIVE@VM-CREATION-TERRAFORM:~$ sudo ss -tlnp | grep ssh
    LISTEN    0         128                0.0.0.0:2222             0.0.0.0:*        users:(("sshd",pid=2158,fd=3))                
    LISTEN    0         128                   [::]:2222                [::]:*        users:(("sshd",pid=2158,fd=4)) 
    ```

  - Preuve qu'une nouvelle connexion sur ce port 2222/tcp ne fonctionne pas à cause du NSG : 
    ```
    PS C:\Users\Florian Andries> ssh PRIVE@4.251.105.150
    ssh: connect to host 4.251.105.150 port 22: Connection refused
    PS C:\Users\Florian Andries> ssh -p 2222 PRIVE@4.251.105.150
    ssh: connect to host 4.251.105.150 port 2222: Connection timed out
    ```

## 2. DNS

Pour ajouter le DNS à la VM, il suffit d'ajouter la propriété ```domain_name_label``` sur la ressource ```azurerm_public_ip``` qui se trouve pour ma part dans mon ```main.tf```, comme suit : 
```
resource "azurerm_public_ip" "main" {
  name                = "vm-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  domain_name_label = var.domain_name_label
  allocation_method   = "Static"
  sku                 = "Standard"
}
```

Pour créer un output personnalisé, nous devons créer un fichier ```outputs.tf``` avec le code suivant : 
```
output "ssh_connection" {
  description = "Affichage de l'IP publique et du nom DNS de  la VM"
  value       = "IP publique : ${azurerm_public_ip.main.ip_address} / Nom DNS : ${azurerm_public_ip.main.domain_name_label}"
}
```

Voici donc la sortie d'un ```terraform apply``` (seulement le output) : 
```
Outputs:

ssh_connection = "IP publique : 4.178.181.211 / Nom DNS : fandries-terraform-2025"
```

- Preuve de la commande ```ssh``` fonctionnelle vers le nom de domaine : 
  ```
  PS C:\Users\Florian Andries> ssh PRIVE@fandries-terraform-2025.francecentral.cloudapp.azure.com
  The authenticity of host 'fandries-terraform-2025.francecentral.cloudapp.azure.com (4.211.250.176)' can't be established.
  ED25519 key fingerprint is SHA256:0YjvIf5ri2wNHLlKp0dTWNJm9sGOJCESQCv7pwns4Hg.
  This key is not known by any other names.
  Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
  Warning: Permanently added 'fandries-terraform-2025.francecentral.cloudapp.azure.com' (ED25519) to the list of known hosts.
  Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1089-azure x86_64)

  * Documentation:  https://help.ubuntu.com
  * Management:     https://landscape.canonical.com
  * Support:        https://ubuntu.com/pro

  System information as of Sun Sep  7 14:54:23 UTC 2025

    System load:  0.09              Processes:             110
    Usage of /:   5.4% of 28.89GB   Users logged in:       0
    Memory usage: 30%               IPv4 address for eth0: 10.0.1.4
    Swap usage:   0%

  Expanded Security Maintenance for Applications is not enabled.

  0 updates can be applied immediately.

  Enable ESM Apps to receive additional future security updates.
  See https://ubuntu.com/esm or run: sudo pro status


  The list of available updates is more than a week old.
  To check for new updates run: sudo apt update


  The programs included with the Ubuntu system are free software;
  the exact distribution terms for each program are described in the
  individual files in /usr/share/doc/*/copyright.

  Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
  applicable law.

  To run a command as administrator (user "root"), use "sudo <command>".
  See "man sudo_root" for details.

  PRIVE@VM-CREATION-TERRAFORM:~$
  ```

## 3. Blob storage

Avant de compléter le plan Terraform pour déployer du Blob Storage pour la VM, il faut tout d'abord ajouter dans la resource ```azurerm_linux_virtual_machine``` la propriété suivante : 
```
identity {
    type = "SystemAssigned"
  }
```

Après cela, nous créons le fichier ```storage.tf``` avec les propriétés suivantes : 

```
# storage.tf

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "meowcontainer" {
  name                  = var.storage_container_name
  storage_account_id = azurerm_storage_account.main.id
  container_access_type = "private"
}

data "azurerm_virtual_machine" "main" {
  name                = azurerm_linux_virtual_machine.main.name
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_role_assignment" "vm_blob_access" {
  principal_id = data.azurerm_virtual_machine.main.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.main.id

  depends_on = [
    azurerm_linux_virtual_machine.main
  ]
}
```

Preuve que tout est bien configuré : 

- Installation de ```azcopy``` sur la VM:
  ```
  PRIVE@VM-CREATION-TERRAFORM:~$ curl -sSL -O https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
  PRIVE@VM-CREATION-TERRAFORM:~$ sudo dpkg -i packages-microsoft-prod.deb
  Selecting previously unselected package packages-microsoft-prod.
  (Reading database ... 59242 files and directories currently installed.)
  Preparing to unpack packages-microsoft-prod.deb ...
  Unpacking packages-microsoft-prod (1.0-ubuntu20.04.1) ...
  Setting up packages-microsoft-prod (1.0-ubuntu20.04.1) ...
  PRIVE@VM-CREATION-TERRAFORM:~$ rm packages-microsoft-prod.deb
  PRIVE@VM-CREATION-TERRAFORM:~$ sudo apt-get update
  PRIVE@VM-CREATION-TERRAFORM:~$ sudo apt-get install azcopy
  ```

- Authentification automatique via la commande ```azcopy login --identity```
  ```
  PRIVE@VM-CREATION-TERRAFORM:~$ azcopy login --identity
  INFO: Login with identity succeeded.
  ```


- Utilisation de la commande ```azcopy``` pour écrire un fichier dans le Storage Container
  ```
  PRIVE@VM-CREATION-TERRAFORM:~$ nano file-test-blob-storage
  PRIVE@VM-CREATION-TERRAFORM:/$ azcopy copy /home/fandries/file-test-blob-storage 'https://PRIVE.blob.core.windows.net/PRIVE/myTextFile.txt'
  INFO: Scanning...
  INFO: Autologin not specified.
  INFO: Authenticating to destination using Azure AD
  INFO: Any empty folders will not be processed, because source and/or destination doesn't have full folder support

  Job 1ffaaf2a-99d2-c343-7132-2c8aee4e3d20 has started
  Log file is located at: /home/PRIVE/.azcopy/1ffaaf2a-99d2-c343-7132-2c8aee4e3d20.log

  100.0 %, 1 Done, 0 Failed, 0 Pending, 0 Skipped, 1 Total, 2-sec Throughput (Mb/s): 0.0001


  Job 1ffaaf2a-99d2-c343-7132-2c8aee4e3d20 summary
  Elapsed Time (Minutes): 0.0334
  Number of File Transfers: 1
  Number of Folder Property Transfers: 0
  Number of Symlink Transfers: 0
  Total Number of Transfers: 1
  Number of File Transfers Completed: 1
  Number of Folder Transfers Completed: 0
  Number of File Transfers Failed: 0
  Number of Folder Transfers Failed: 0
  Number of File Transfers Skipped: 0
  Number of Folder Transfers Skipped: 0
  Number of Symbolic Links Skipped: 0
  Number of Hardlinks Converted: 0
  Number of Special Files Skipped: 0
  Total Number of Bytes Transferred: 14
  Final Job Status: Completed
  ```

- Utilisation de la commande ```azcopy``` pour lire le fichier que l'on vient de push

  ```
  PRIVE@VM-CREATION-TERRAFORM:/$ azcopy copy 'https://PRIVE.blob.core.windows.net/PRIVE/myTe
  xtFile.txt' /home/PRIVE/myfilefromstorage
  INFO: Scanning...
  INFO: Autologin not specified.
  INFO: Authenticating to source using Azure AD
  INFO: Any empty folders will not be processed, because source and/or destination doesn't have full folder support

  Job b14dfd0b-9ab8-ef4f-6578-9fb4005c70f4 has started
  Log file is located at: /home/PRIVE/.azcopy/b14dfd0b-9ab8-ef4f-6578-9fb4005c70f4.log

  100.0 %, 1 Done, 0 Failed, 0 Pending, 0 Skipped, 1 Total, 2-sec Throughput (Mb/s): 0.0001


  Job b14dfd0b-9ab8-ef4f-6578-9fb4005c70f4 summary
  Elapsed Time (Minutes): 0.0334
  Number of File Transfers: 1
  Number of Folder Property Transfers: 0
  Number of Symlink Transfers: 0
  Total Number of Transfers: 1
  Number of File Transfers Completed: 1
  Number of Folder Transfers Completed: 0
  Number of File Transfers Failed: 0
  Number of Folder Transfers Failed: 0
  Number of File Transfers Skipped: 0
  Number of Folder Transfers Skipped: 0
  Number of Symbolic Links Skipped: 0
  Number of Hardlinks Converted: 0
  Number of Special Files Skipped: 0
  Total Number of Bytes Transferred: 14
  Final Job Status: Completed
  ```

- Explication de comment ```azcopy login --identity``` nous authentifie :

  La VM que l'on crée possède une Managed Identity (MI) qui est créé automatiquement par Azure. De notre côté, nous devons l'activer avec le paramètre suivant : 
  ```
  identity {
    type = "SystemAssigned"
  }
  ```

  Quand nous réalisons la commande ```azcopy login --identity```, AzCopy demande un jeton d'accès à Azure via la MI.

  Azure AD va renvoyer un jeton temporaire qui prouve que la VM est bien autorisée.

  AzCopy utilise alors ce jeton pour accéder au Storage Account, en vérifiant notre rôle. C'est directement l'identité de la VM qui sert d'authentification.

- Requête d'un JWT d'autehntification auprès du service que nous veons de nous identifier, manuellement : 
  ```
  PRIVE@VM-CREATION-TERRAFORM:~$ curl -H "Metadata: true" \
  >      "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-15&resource=https://storage.azure.com/"
  {"access_token":"PRIVE","client_id":"PRIVE","expires_in":"86400","expires_on":"1757452513","ext_expires_in":"86399","not_before":"1757365813","resource":"https://storage.azure.com/","token_type":"Bearer"}
  ```

- Explication de la joignabilité de l'IP ```169.254.169.254``` : 

  - L'IP ```169.254.169.254``` est spécialement réservé pour le Metadata Service d'Azure.

  - Elle n'est pas sur internet mais accessible depuis chaque VM via un réseau interne.

  - Pourquoi ? Car elle se trouve dans sa table de routage. Cette IP est link-local.

  - Cette IP permet d'intérroger directement le service de métadonnées de la VM, qui se trouve en local sur la VM.

## 4. Monitoring 

Avant de créer le fichier, il faut ajouter la variables dans le fichier ```variables.tf``` : 
```
variable "alert_email_address" {
  type        = string
  description = "Email address to receive alerts"
}
```

Création du fichier ```monitoring.tf``` : 
```
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.resource_group_name}-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "vm-alerts"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email_address
  }
}

# CPU Metric Alert (using platform metrics)
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-alert-${azurerm_linux_virtual_machine.main.name}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_virtual_machine.main.id]
  description         = "Alert when CPU usage exceeds 70%"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  window_size   = "PT5M"
  frequency     = "PT1M"
  auto_mitigate = true

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

Avant d'ajouter l'alerte pour la mémoire RAM de la VM, je dois installer sur la VM l'extension AzureMonitorLinuxAgent" qui me permet de récupérer les métriques de la RAM de la VM : 
```
# Azure Monitor Agent (remplace LinuxDiagnostic)
resource "azurerm_virtual_machine_extension" "ama" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.main.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}
```
J'ajoute donc un workspace qui va me permettre de récupérer, stocker et lire les logs récupéré par l'extension : 
```
# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.resource_group_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Data Collection Rule
resource "azurerm_monitor_data_collection_rule" "main" {
  name                = "dcr-${var.resource_group_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  destinations {
    log_analytics {
      name                  = "to-law"
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["to-law"]
  }

  data_sources {
    performance_counter {
      name                          = "perfCounters"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time", # CPU
        "\\Memory\\Available MBytes"            # RAM dispo
      ]
    }
  }
}

# Associer la DCR à la VM
resource "azurerm_monitor_data_collection_rule_association" "main" {
  name                    = "assoc-${azurerm_linux_virtual_machine.main.name}"
  target_resource_id      = azurerm_linux_virtual_machine.main.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.main.id
}
```
Ajout de l'alerte si la mémoire RAM de la VM est en dessous de 512M : 
```
# Memory Alert (via Log Analytics query)
resource "azurerm_monitor_scheduled_query_rules_alert" "memory_alert" {
  name                = "memory-alert-${azurerm_linux_virtual_machine.main.name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  description         = "Alert when available memory < 512 MB"
  severity            = 2
  enabled             = true

  # Évaluation toutes les 5 minutes sur une fenêtre de 5 minutes
  frequency   = 5
  time_window = 5

  # Log Analytics Workspace comme source
  data_source_id = azurerm_log_analytics_workspace.main.id

  query = <<-QUERY
    Perf
    | where ObjectName == "Memory" and CounterName == "Available MBytes"
    | summarize AvgValue = avg(CounterValue) by bin(TimeGenerated, 5m)
    | where AvgValue < 512
  QUERY

  trigger {
    operator  = "LessThan"
    threshold = 512
  }

  action {
    action_group = [azurerm_monitor_action_group.main.id]
  }
}
```
Affichage des alertes CPU et RAM avec la commande ```az``` (2 commandes différentes car l'alerte CPU se repose sur une métrique système et l'alerte RAM se repose sur une log récupéré par le workspace Log Analytics):
- Pour l'alerte CPU : 
  ```
   az monitor metrics alert list --resource-group PRIVE -o table
  AutoMitigate    Description                       Enabled    EvaluationFrequency    Location    Name                             ResourceGroup                 Severity    TargetResourceRegion    TargetResourceType    WindowSize
  --------------  --------------------------------  ---------  ---------------------  ----------  -------------------------------  ----------------------------  ----------  ----------------------  --------------------  ------------
  True            Alert when CPU usage exceeds 70%  True       PT1M                   global      cpu-alert-VM-CREATION-TERRAFORM  PRIVE  2                                                         PT5M
  ```
- Pour l'alerte RAM :
  ```
  az monitor scheduled-query list --resource-group PRIVE
  C:\Users\Florian Andries\.azure\cliextensions\scheduled-query\azext_scheduled_query\vendored_sdks\__init__.py:6: UserWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html. The pkg_resources package is slated for removal as early as 2025-11-30. Refrain from using this package or pin to Setuptools<81.
    __import__('pkg_resources').declare_namespace(__name__)
  [
    {
      "actions": {
        "actionGroups": [
          "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Insights/actionGroups/ag-PRIVE-alerts"
        ],
        "customProperties": null
      },
      "autoMitigate": false,
      "checkWorkspaceAlertsStorageConfigured": null,
      "createdWithApiVersion": "2018-04-16",
      "criteria": {
        "allOf": [
          {
            "dimensions": null,
            "failingPeriods": {
              "minFailingPeriodsToAlert": 1,
              "numberOfEvaluationPeriods": 1
            },
            "metricMeasureColumn": "",
            "metricName": null,
            "operator": "LessThan",
            "query": "Perf\r\n| where ObjectName == \"Memory\" and CounterName == \"Available MBytes\"\r\n| summarize AvgValue = avg(CounterValue) by bin(TimeGenerated, 5m)\r\n| where AvgValue < 512\r\n",
            "resourceIdColumn": null,
            "threshold": 512.0,
            "timeAggregation": "Count"
          }
        ]
      },
      "description": "Alert when available memory < 512 MB",
      "displayName": null,
      "enabled": true,
      "etag": null,
      "evaluationFrequency": "0:05:00",
      "id": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/microsoft.insights/scheduledqueryrules/memory-alert-VM-CREATION-TERRAFORM",
      "isLegacyLogAnalyticsRule": null,
      "isWorkspaceAlertsStorageConfigured": null,
      "kind": null,
      "location": "francecentral",
      "muteActionsDuration": null,
      "name": "memory-alert-VM-CREATION-TERRAFORM",
      "overrideQueryTimeRange": null,
      "resourceGroup": "PRIVE",
      "scopes": [
        "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.OperationalInsights/workspaces/law-PRIVE"
      ],
      "severity": 2,
      "skipQueryValidation": null,
      "systemData": {
        "createdAt": "2025-09-13T09:38:06.820611+00:00",
        "createdBy": "PRIVE",
        "createdByType": "User",
        "lastModifiedAt": "2025-09-13T09:38:06.820611+00:00",
        "lastModifiedBy": "PRIVE",
        "lastModifiedByType": "User"
      },
      "tags": {},
      "targetResourceTypes": null,
      "type": "Microsoft.Insights/scheduledQueryRules",
      "windowSize": "0:05:00"
    }
  ]
  ```
Installation du paquet ```stress-ng``` sur la VM :
```
PRIVE@VM-CREATION-TERRAFORM:~$ sudo apt-get install -y stress-ng
```

Commande stress pour le CPU :
```
PRIVE@VM-CREATION-TERRAFORM:~$ stress-ng --cpu 0 --timeout 300s
stress-ng: info:  [23506] dispatching hogs: 1 cpu
```

Commande stress pour la RAM :
```
PRIVE@VM-CREATION-TERRAFORM:~$ stress-ng --vm 1 --vm-bytes 1G --timeout 600s
stress-ng: info:  [23786] dispatching hogs: 1 vm
```

Côté interface utilisateur d'Azure, on peut donc bien voir les 2 alertes, et que les 2 sont au statut "Fired".

Vérification que les alertes ont été fired avec la commande ```az monitor activity-log``` : 
- Alerte RAM : 
  ```
    az monitor activity-log list
    {
      "authorization": {
        "action": "Microsoft.Compute/virtualMachines/write",
        "scope": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Compute/virtualMachines/VM-CREATION-TERRAFORM"
      },
      "caller": "PRIVE",
      "category": {
        "localizedValue": "Policy",
        "value": "Policy"
      },
      "claims": {
        "acrs": "p1",
        "aio": "AXQAi/8ZAAAAWK175dZQDhsG2B9rzW3VP1MFjbaWAKPR6Pr63Fv4dog/Y2V5itP5MQfl7IqofljwpPAtudxDOq2d5/m4hkwVABF9vVnNYvhHj2FxRwdCmGyTKR1QMdK17gIQPp/ZOrYr4pK0H8Y+Ji2bfdcuvzT5lA==",
        "appid": "04b07795-8ddb-461a-bbee-02f9e1bf7b46",
        "appidacr": "0",
        "aud": "https://management.azure.com",
        "exp": "1757759577",
        "groups": "f15d224c-4eff-43e3-ac9f-b0b124914a5c,c9603c51-8a06-4e95-bf37-51caca1a8a20,e9d4ef5f-c577-42d8-b19a-1beedc6598f8,07bbfa7e-387d-42c3-bddc-b68dc7b81633,18bf18a2-7db8-4806-9833-cde48c6b21ba",
        "http://schemas.microsoft.com/2012/01/devicecontext/claims/identifier": "4379c693-e546-4d21-9f34-53d0df547d8f",
        "http://schemas.microsoft.com/claims/authnclassreference": "1",
        "http://schemas.microsoft.com/claims/authnmethodsreferences": "pwd,rsa,mfa",
        "http://schemas.microsoft.com/identity/claims/objectidentifier": "06a53fe9-3b8a-4dea-8564-bc417dd440d9",
        "http://schemas.microsoft.com/identity/claims/scope": "user_impersonation",
        "http://schemas.microsoft.com/identity/claims/tenantid": "413600cf-bd4e-4c7c-8a61-69e73cddf731",
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname": "Florian",
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name": "PRIVE",
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier": "SqF5bwKIc4zpTwvLQyolGg3dKVDFM1RV6B66x8FPv7o",
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname": "ANDRIES",
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn": "PRIVE",
        "iat": "1757754093",
        "idtyp": "user",
        "ipaddr": "2001:861:6050:7870:453e:f07e:27d0:39fe",
        "iss": "https://sts.windows.net/413600cf-bd4e-4c7c-8a61-69e73cddf731/",
        "name": "Florian ANDRIES",
        "nbf": "1757754093",
        "onprem_sid": "S-1-5-21-2679834606-364742315-399831736-51944",
        "puid": "10032004FAF33F1D",
        "pwd_url": "https://portal.microsoftonline.com/ChangePassword.aspx",
        "rh": "1.ATsAzwA2QU69fEyKYWnnPN33MUZIf3kAutdPukPawfj2MBMVAeg7AA.",
        "sid": "0089aa49-bace-8735-8e4c-b257ddfbeca3",
        "uti": "2dJbLVD7J0ePuYTrT_gdAQ",
        "ver": "1.0",
        "wids": "b79fbf4d-3ef9-4689-8143-76b194e85509",
        "xms_ftd": "8Z3jhpA1hr_7UCZIYHDIfskZG9nea51dMUa0rmXW5xkBZXVyb3Bld2VzdC1kc21z",
        "xms_idrel": "28 1",
        "xms_tcdt": "1362071595"
      },
      "correlationId": "83fdd7bb-e74d-6c6a-4d3f-739b78c293a0",
      "description": "",
      "eventDataId": "2df01dba-6e89-4a10-8d57-3351ed2648b8",
      "eventName": {
        "localizedValue": "End request",
        "value": "EndRequest"
      },
      "eventTimestamp": "2025-09-13T09:47:24.2025247Z",
      "id": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Compute/virtualMachines/VM-CREATION-TERRAFORM/events/2df01dba-6e89-4a10-8d57-3351ed2648b8/ticks/638933536442025247",
      "level": "Informational",
      "operationId": "2a50b2e1-f5b5-4947-84cd-167bbe231645",
      "operationName": {
        "localizedValue": "'auditIfNotExists' Policy action.",
        "value": "Microsoft.Authorization/policies/auditIfNotExists/action"
      },
      "properties": {
        "ancestors": "413600cf-bd4e-4c7c-8a61-69e73cddf731",
        "entity": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Compute/virtualMachines/VM-CREATION-TERRAFORM",
        "eventCategory": "Policy",
        "hierarchy": "",
        "isComplianceCheck": "False",
        "message": "Microsoft.Authorization/policies/auditIfNotExists/action",
        "policies": "[{\"policyDefinitionId\":\"/providers/Microsoft.Authorization/policyDefinitions/bb91dfba-c30d-4263-9add-9c2384e659a6\",\"policySetDefinitionId\":\"/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8\",\"policyDefinitionReferenceId\":\"networkSecurityGroupsOnInternalVirtualMachinesMonitoring\",\"policySetDefinitionName\":\"1f3afdf9-d0c9-4c3d-847f-89da613e70a8\",\"policySetDefinitionDisplayName\":\"Microsoft cloud security benchmark\",\"policySetDefinitionVersion\":\"57.54.0\",\"policyDefinitionName\":\"bb91dfba-c30d-4263-9add-9c2384e659a6\",\"policyDefinitionDisplayName\":\"Non-internet-facing virtual machines should be protected with network security groups\",\"policyDefinitionVersion\":\"3.0.0\",\"policyDefinitionEffect\":\"AuditIfNotExists\",\"policyAssignmentId\":\"/subscriptions/PRIVE/providers/Microsoft.Authorization/policyAssignments/SecurityCenterBuiltIn\",\"policyAssignmentName\":\"SecurityCenterBuiltIn\",\"policyAssignmentDisplayName\":\"ASC Default (subscription: PRIVE)\",\"policyAssignmentScope\":\"/subscriptions/PRIVE\",\"policyExemptionIds\":[],\"policyEnrollmentIds\":[]}]",
        "resourceLocation": "francecentral"
      },
      "resourceGroup": "PRIVE",
      "resourceGroupName": "PRIVE",
      "resourceId": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Compute/virtualMachines/VM-CREATION-TERRAFORM",
      "resourceProviderName": {
        "localizedValue": "Microsoft.Compute",
        "value": "Microsoft.Compute"
      },
      "resourceType": {
        "localizedValue": "Microsoft.Compute/virtualMachines",
        "value": "Microsoft.Compute/virtualMachines"
      },
      "status": {
        "localizedValue": "Succeeded",
        "value": "Succeeded"
      },
      "subStatus": {
        "localizedValue": "",
        "value": ""
      },
      "submissionTimestamp": "2025-09-13T09:48:34Z",
      "subscriptionId": "PRIVE",
      "tenantId": "413600cf-bd4e-4c7c-8a61-69e73cddf731"
    },
  ```
- Alerte cpu : 
  ```
  az monitor metrics alert list --resource-group PRIVE
  [
    {
      "actions": [
        {
          "actionGroupId": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Insights/actionGroups/ag-PRIVE-alerts",
          "webHookProperties": {}
        }
      ],
      "autoMitigate": true,
      "criteria": {
        "allOf": [
          {
            "criterionType": "StaticThresholdCriterion",
            "metricName": "Percentage CPU",
            "metricNamespace": "Microsoft.Compute/virtualMachines",
            "name": "Metric1",
            "operator": "GreaterThan",
            "skipMetricValidation": false,
            "threshold": 70.0,
            "timeAggregation": "Average"
          }
        ],
        "odata.type": "Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria"
      },
      "description": "Alert when CPU usage exceeds 70%",
      "enabled": true,
      "evaluationFrequency": "PT1M",
      "id": "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Insights/metricAlerts/cpu-alert-VM-CREATION-TERRAFORM",
      "location": "global",
      "name": "cpu-alert-VM-CREATION-TERRAFORM",
      "resourceGroup": "PRIVE",
      "scopes": [
        "/subscriptions/PRIVE/resourceGroups/PRIVE/providers/Microsoft.Compute/virtualMachines/VM-CREATION-TERRAFORM"
      ],
      "severity": 2,
      "tags": {},
      "targetResourceRegion": "",
      "targetResourceType": "",
      "type": "Microsoft.Insights/metricAlerts",
      "windowSize": "PT5M"
    }
  ]
  ```

## 5. Vault

Création du fichier ```keyvault.tf``` : 
```
# data pour récupérer tenant_id et object_id du compte courant
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "meow_vault" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_linux_virtual_machine.main.identity[0].principal_id
    secret_permissions = [
      "Get", "List"
    ]
  }
}

resource "random_password" "meow_secret" {
  length           = 16
  special          = true
  override_special = "@#$%^&*()"
}

resource "azurerm_key_vault_secret" "meow_secret" {
  name         = var.key_vault_secret_name
  value        = random_password.meow_secret.result
  key_vault_id = azurerm_key_vault.meow_vault.id
}
```

Affichage du secret avec la commande ```az``` : 
```
az keyvault secret show --name meowsecretflo2025 --vault-name meowvaultflo2025 --query "value" -o tsv
%d4slq)xy(de7H@e
```

Affichage du secret depuis la VM, avec le script suivant : 
```
#!/bin/bash
VAULT_NAME="meowvaultflo2025"
SECRET_NAME="meowsecretflo2025"

ACCESS_TOKEN=$(curl -s -H "Metadata:true" \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net" \
  | jq -r '.access_token')

SECRET_VALUE=$(curl -s \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://$VAULT_NAME.vault.azure.net/secrets/$SECRET_NAME?api-version=7.2" \
  | jq -r '.value')

echo "Valeur du secret $SECRET_NAME : $SECRET_VALUE"
```
Une fois le script créé, il faut donner les droits nécessaires d'exécution :
```
chmod +x script.sh
```
Enfin, il nous suffit de lancer le script pour obtenir le secret : 
```
PRIVE@VM-CREATION-TERRAFORM:~$ sudo ./script.sh
Valeur du secret meowsecretflo2025 : %d4slq)xy(de7H@e
```
