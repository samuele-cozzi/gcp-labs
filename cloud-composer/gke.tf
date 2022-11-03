# resource "google_service_account" "default" {
#   account_id   = "service-account-id"
#   display_name = "Service Account"
# }

# resource "google_container_cluster" "primary" {
#   name     = "my-gke-cluster"
#   location = "us-central1"

#   # We can't create a cluster with no node pool defined, but we want to only use
#   # separately managed node pools. So we create the smallest possible default
#   # node pool and immediately delete it.
#   remove_default_node_pool = true
#   initial_node_count       = 1
# }

# resource "google_container_node_pool" "primary_preemptible_nodes" {
#   name       = "my-node-pool"
#   location   = "us-central1"
#   cluster    = google_container_cluster.primary.name
#   node_count = 1

#   node_config {
#     preemptible  = true
#     machine_type = "e2-small"

#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     service_account = google_service_account.default.email
#     oauth_scopes    = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
# }





variable "project" {
  type = string
  description = "qwiklabs-gcp-00-bff05ce96149"
}

provider "google-beta" {
  project = var.project
  region  = "us-central1"
}

resource "google_project_service" "composer_api" {
  provider = google-beta
  project = var.project
  service = "composer.googleapis.com"
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  disable_on_destroy = false
}

resource "google_service_account" "custom_service_account" {
  provider = google-beta
  account_id   = "custom-service-account"
  display_name = "Example Custom Service Account"
}

resource "google_project_iam_member" "custom_service_account" {
  provider = google-beta
  project  = var.project
  member   = format("serviceAccount:%s", google_service_account.custom_service_account.email)
  // Role for Public IP environments
  role     = "roles/composer.admin"
}

resource "google_project_iam_member" "custom_service_account" {
  provider = google-beta
  project  = var.project
  member   = format("serviceAccount:%s", google_service_account.custom_service_account.email)
  // Role for Public IP environments
  role     = "roles/composer.worker"
}

resource "google_project_iam_member" "custom_service_account" {
  provider = google-beta
  project  = var.project
  member   = format("serviceAccount:%s", google_service_account.custom_service_account.email)
  // Role for Public IP environments
  role     = "roles/composer.ServiceAgentV2Ext"
}

resource "google_service_account_iam_member" "custom_service_account" {
  provider = google-beta
  service_account_id = google_service_account.custom_service_account.name
  role = "roles/composer.ServiceAgentV2Ext"
  member = format("serviceAccount:%s", google_service_account.custom_service_account.email)
}

resource "google_composer_environment" "example_environment" {
  provider = google-beta
  name = "example-environment"

  config {
    software_config {
      image_version = "composer-2.0.29-airflow-2.1.4"
    }

    node_config {
      service_account = google_service_account.custom_service_account.email
    }

  }
}
