resource "shoreline_notebook" "mysql_instance_restart_incident" {
  name       = "mysql_instance_restart_incident"
  data       = file("${path.module}/data/mysql_instance_restart_incident.json")
  depends_on = [shoreline_action.invoke_check_log_file_exists,shoreline_action.invoke_error_check,shoreline_action.invoke_mysql_config_update]
}

resource "shoreline_file" "check_log_file_exists" {
  name             = "check_log_file_exists"
  input_file       = "${path.module}/data/check_log_file_exists.sh"
  md5              = filemd5("${path.module}/data/check_log_file_exists.sh")
  description      = "Check if the log file exists"
  destination_path = "/agent/scripts/check_log_file_exists.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "error_check" {
  name             = "error_check"
  input_file       = "${path.module}/data/error_check.sh"
  md5              = filemd5("${path.module}/data/error_check.sh")
  description      = "Check if there are any errors"
  destination_path = "/agent/scripts/error_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "mysql_config_update" {
  name             = "mysql_config_update"
  input_file       = "${path.module}/data/mysql_config_update.sh"
  md5              = filemd5("${path.module}/data/mysql_config_update.sh")
  description      = "Review the configuration settings of the MySQL instance to ensure that they are not causing the restart."
  destination_path = "/agent/scripts/mysql_config_update.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_log_file_exists" {
  name        = "invoke_check_log_file_exists"
  description = "Check if the log file exists"
  command     = "`chmod +x /agent/scripts/check_log_file_exists.sh && /agent/scripts/check_log_file_exists.sh`"
  params      = []
  file_deps   = ["check_log_file_exists"]
  enabled     = true
  depends_on  = [shoreline_file.check_log_file_exists]
}

resource "shoreline_action" "invoke_error_check" {
  name        = "invoke_error_check"
  description = "Check if there are any errors"
  command     = "`chmod +x /agent/scripts/error_check.sh && /agent/scripts/error_check.sh`"
  params      = []
  file_deps   = ["error_check"]
  enabled     = true
  depends_on  = [shoreline_file.error_check]
}

resource "shoreline_action" "invoke_mysql_config_update" {
  name        = "invoke_mysql_config_update"
  description = "Review the configuration settings of the MySQL instance to ensure that they are not causing the restart."
  command     = "`chmod +x /agent/scripts/mysql_config_update.sh && /agent/scripts/mysql_config_update.sh`"
  params      = ["PATH_TO_MYSQL_CONFIG_FILE","OLD_VALUE","MAX_CONNECTIONS"]
  file_deps   = ["mysql_config_update"]
  enabled     = true
  depends_on  = [shoreline_file.mysql_config_update]
}

