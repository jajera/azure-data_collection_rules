resource "azurerm_resource_group" "main" {
  name     = "azure-dcr"
  location = "southeastasia"
  tags     = { usage = "azure-data_collection_rules" }
}

resource "random_password" "pw" {
  length  = 14
  special = false
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "loganalytics1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 365
  tags                = azurerm_resource_group.main.tags
}

resource "azurerm_monitor_data_collection_rule" "dcrinsights" {
  name                = "dcr-insights1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "VMInsightsPerf-Logs-Dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["VMInsightsPerf-Logs-Dest"]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
      name                          = "VMInsightsPerfCounters"
    }
  }

  description = "Data collection rule for VM Insights."
  tags        = azurerm_resource_group.main.tags
}

resource "azurerm_monitor_data_collection_rule" "dcrwinevents" {
  name                = "dcr-windowsevents1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "VMEvent-Logs-Dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["VMEvent-Logs-Dest"]
  }

  data_sources {
    windows_event_log {
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=5)]]",
        "Security!*[System[(band(Keywords,13510798882111488))]]",
        "System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=5)]]"
      ]
      name = "eventLogsDataSource"
    }
  }

  description = "Data collection rule for Windows Event Logs."
  tags        = azurerm_resource_group.main.tags
}

resource "azurerm_monitor_data_collection_rule" "dcrperfcounter" {
  name                = "dcr-perfcounter1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "VMPerf-Counter-Dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["VMPerf-Counter-Dest"]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 10
      counter_specifiers = [
        "\\Processor Information(_Total)\\% Processor Time",
        "\\Processor Information(_Total)\\% Privileged Time",
        "\\Processor Information(_Total)\\% User Time",
        "\\Processor Information(_Total)\\Processor Frequency",
        "\\System\\Processes",
        "\\Process(_Total)\\Thread Count",
        "\\Process(_Total)\\Handle Count",
        "\\System\\System Up Time",
        "\\System\\Context Switches/sec",
        "\\System\\Processor Queue Length",
        "\\Memory\\% Committed Bytes In Use",
        "\\Memory\\Available Bytes",
        "\\Memory\\Committed Bytes",
        "\\Memory\\Cache Bytes",
        "\\Memory\\Pool Paged Bytes",
        "\\Memory\\Pool Nonpaged Bytes",
        "\\Memory\\Pages/sec",
        "\\Memory\\Page Faults/sec",
        "\\Process(_Total)\\Working Set",
        "\\Process(_Total)\\Working Set - Private",
        "\\LogicalDisk(_Total)\\% Disk Time",
        "\\LogicalDisk(_Total)\\% Disk Read Time",
        "\\LogicalDisk(_Total)\\% Disk Write Time",
        "\\LogicalDisk(_Total)\\% Idle Time",
        "\\LogicalDisk(_Total)\\Disk Bytes/sec",
        "\\LogicalDisk(_Total)\\Disk Read Bytes/sec",
        "\\LogicalDisk(_Total)\\Disk Write Bytes/sec",
        "\\LogicalDisk(_Total)\\Disk Transfers/sec",
        "\\LogicalDisk(_Total)\\Disk Reads/sec",
        "\\LogicalDisk(_Total)\\Disk Writes/sec",
        "\\LogicalDisk(_Total)\\Avg. Disk sec/Transfer",
        "\\LogicalDisk(_Total)\\Avg. Disk sec/Read",
        "\\LogicalDisk(_Total)\\Avg. Disk sec/Write",
        "\\LogicalDisk(_Total)\\Avg. Disk Queue Length",
        "\\LogicalDisk(_Total)\\Avg. Disk Read Queue Length",
        "\\LogicalDisk(_Total)\\Avg. Disk Write Queue Length",
        "\\LogicalDisk(_Total)\\% Free Space",
        "\\LogicalDisk(_Total)\\Free Megabytes",
        "\\Network Interface(*)\\Bytes Total/sec",
        "\\Network Interface(*)\\Bytes Sent/sec",
        "\\Network Interface(*)\\Bytes Received/sec",
        "\\Network Interface(*)\\Packets/sec",
        "\\Network Interface(*)\\Packets Sent/sec",
        "\\Network Interface(*)\\Packets Received/sec",
        "\\Network Interface(*)\\Packets Outbound Errors",
        "\\Network Interface(*)\\Packets Received Errors"
      ]
      name = "perfCounterDataSource10"
    }
  }

  description = "Data collection rule for Performance Counters."
  tags        = azurerm_resource_group.main.tags
}

resource "azurerm_monitor_data_collection_rule" "dcrlinuxsyslogs" {
  name                = "dcr-linuxsyslogs1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "VM-Syslog-Dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["VM-Syslog-Dest"]
  }

  data_sources {
    syslog {
      facility_names = [
        "auth",
        "authpriv",
        "cron",
        "daemon",
        "mark",
        "kern",
        "local0",
        "local1",
        "local2",
        "local3",
        "local4",
        "local5",
        "local6",
        "local7",
        "lpr",
        "mail",
        "news",
        "syslog",
        "user",
        "uucp"
      ]
      log_levels = [
        "Debug",
        "Info",
        "Notice",
        "Warning",
        "Error",
        "Critical",
        "Alert",
        "Emergency"
      ]
      name = "sysLogsDataSource-1688419672"
    }
  }

  description = "Data collection rule for Linux Syslogs."
  tags        = azurerm_resource_group.main.tags
}

resource "azurerm_monitor_data_collection_rule_association" "dcra-insight" {
  for_each = {
    for vm in data.azurerm_virtual_machine.main : vm.name => vm
  }

  name                    = "dcra-insight"
  target_resource_id      = each.value.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcrinsights.id
  description             = "Data collection rule association for VM Insights."
}

resource "azurerm_monitor_data_collection_rule_association" "dcra-perfcounter" {
  for_each = {
    for vm in data.azurerm_virtual_machine.main : vm.name => vm
  }

  name                    = "dcra-perfcounter"
  target_resource_id      = each.value.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcrperfcounter.id
  description             = "Data collection rule association for Performance Counters."
}

resource "azurerm_monitor_data_collection_rule_association" "dcra-dcrwinevents" {
  name                    = "dcra-dcrwinevents"
  target_resource_id      = azurerm_windows_virtual_machine.main.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcrwinevents.id
  description             = "Data collection rule association for Windows Event Logs."
}

resource "azurerm_monitor_data_collection_rule_association" "dcra-linuxsyslogs" {
  name                    = "dcra-linuxsyslogs"
  target_resource_id      = azurerm_linux_virtual_machine.main.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcrlinuxsyslogs.id
  description             = "Data collection rule association for Syslogs."
}
