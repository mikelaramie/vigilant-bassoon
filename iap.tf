// Check for appropriate APIs enabled
resource "google_project_service" "gcp_iap_services" {
  count              = var.enable_iap ? 1 : 0
  service            = "iap.googleapis.com"
  disable_on_destroy = false
}

// Get current user's email address
data "google_client_openid_userinfo" "me" {
}

// Configure OAuth brand and client
resource "google_iap_brand" "project_brand" {
  count             = var.enable_iap ? 1 : 0
  support_email     = data.google_client_openid_userinfo.me.email
  application_title = "Cloud IAP protected Application"
  project           = var.project_id
}

resource "google_iap_client" "project_client" {
  count        = var.enable_iap ? 1 : 0
  display_name = "Test Client"
  brand        = google_iap_brand.project_brand[0].name
}
