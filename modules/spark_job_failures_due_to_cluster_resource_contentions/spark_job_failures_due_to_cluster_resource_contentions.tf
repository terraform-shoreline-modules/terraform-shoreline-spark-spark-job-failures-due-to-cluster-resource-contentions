resource "shoreline_notebook" "spark_job_failures_due_to_cluster_resource_contentions" {
  name       = "spark_job_failures_due_to_cluster_resource_contentions"
  data       = file("${path.module}/data/spark_job_failures_due_to_cluster_resource_contentions.json")
  depends_on = [shoreline_action.invoke_resource_checker,shoreline_action.invoke_increase_cluster_limits]
}

resource "shoreline_file" "resource_checker" {
  name             = "resource_checker"
  input_file       = "${path.module}/data/resource_checker.sh"
  md5              = filemd5("${path.module}/data/resource_checker.sh")
  description      = "Not enough resources allocated to the Spark job causing it to compete with other jobs running on the cluster."
  destination_path = "/agent/scripts/resource_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "increase_cluster_limits" {
  name             = "increase_cluster_limits"
  input_file       = "${path.module}/data/increase_cluster_limits.sh"
  md5              = filemd5("${path.module}/data/increase_cluster_limits.sh")
  description      = "Increasing the resources allocated to the cluster, like memory and CPU, to avoid contention."
  destination_path = "/agent/scripts/increase_cluster_limits.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_resource_checker" {
  name        = "invoke_resource_checker"
  description = "Not enough resources allocated to the Spark job causing it to compete with other jobs running on the cluster."
  command     = "`chmod +x /agent/scripts/resource_checker.sh && /agent/scripts/resource_checker.sh`"
  params      = ["CLUSTER_PROCESS_NAME","JOB_ID"]
  file_deps   = ["resource_checker"]
  enabled     = true
  depends_on  = [shoreline_file.resource_checker]
}

resource "shoreline_action" "invoke_increase_cluster_limits" {
  name        = "invoke_increase_cluster_limits"
  description = "Increasing the resources allocated to the cluster, like memory and CPU, to avoid contention."
  command     = "`chmod +x /agent/scripts/increase_cluster_limits.sh && /agent/scripts/increase_cluster_limits.sh`"
  params      = ["NEW_CPU_VALUE","CLUSTER_PROCESS_NAME","NEW_MEMORY_VALUE"]
  file_deps   = ["increase_cluster_limits"]
  enabled     = true
  depends_on  = [shoreline_file.increase_cluster_limits]
}

