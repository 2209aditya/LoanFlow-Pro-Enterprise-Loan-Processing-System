resource "azurerm_mssql_server" "sql" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Password@1234"
}

resource "azurerm_mssql_database" "db" {
  name      = "loanflowdb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
}