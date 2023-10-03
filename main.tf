terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "spark_job_failures_due_to_cluster_resource_contentions" {
  source    = "./modules/spark_job_failures_due_to_cluster_resource_contentions"

  providers = {
    shoreline = shoreline
  }
}