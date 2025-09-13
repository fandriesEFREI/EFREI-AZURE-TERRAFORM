# Action Group (envoi email)
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.resource_group_name}-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "vm-alerts"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email_address
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.resource_group_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Azure Monitor Agent (remplace LinuxDiagnostic)
resource "azurerm_virtual_machine_extension" "ama" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.main.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
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
  depends_on = [
    azurerm_log_analytics_workspace.main
  ]
}

# Associer la DCR à la VM
resource "azurerm_monitor_data_collection_rule_association" "main" {
  name                    = "assoc-${azurerm_linux_virtual_machine.main.name}"
  target_resource_id      = azurerm_linux_virtual_machine.main.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.main.id
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
  
  depends_on = [
    azurerm_monitor_data_collection_rule.main
  ]
}