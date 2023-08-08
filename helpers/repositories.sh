#! /bin/zsh

#GCP
export gcp_project_id="mikelaramie-gke-demos"
export gcp_gar_region="us-central1"

# The version of images from https://github.com/GoogleCloudPlatform/bank-of-anthos/tree/main/kubernetes-manifests
export boa_source_repo="us-central1-docker.pkg.dev/bank-of-anthos-ci"
export boa_app_name="bank-of-anthos"
export boa_app_version="v0.6.1" 

# The version of images from https://github.com/GoogleCloudPlatform/microservices-demo/blob/main/release/kubernetes-manifests.yaml
export ob_source_repo="gcr.io/google-samples"
export ob_app_name="microservices-demo"
export ob_app_version="v0.8.0" 
