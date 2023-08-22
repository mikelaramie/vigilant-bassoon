# vigilant-bassoon
Bank of Anthos Version = 0.6.1

Note:  You must run this at least one time with `bankofanthos` and `enable_iap` both set to false.  The kubernetes objects cannot be created until after the GKE cluster exists.

# terraform-docs

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.77.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.aoss-java-repository](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository.aoss-python-repository](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository.boa-repository](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_member.aoss-java-member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_artifact_registry_repository_iam_member.aoss-python-member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_artifact_registry_repository_iam_member.boa-member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_compute_network.gke-cluster-01-network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_container_cluster.gke-cluster-01](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.gke-project-01-cluster-01-pool-01](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_iap_brand.project_brand](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_brand) | resource |
| [google_iap_client.project_client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client) | resource |
| [google_project_iam_member.gke-cluster-01-trace](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.gcp-gar-services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.gcp_gke_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.gcp_iap_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.gke-cluster-01](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [kubectl_manifest.bankofanthos](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.bankofanthos-secret](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.iap-backendconfig](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.bankofanthos](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.bankofanthos-iap-oauth-client](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [google_artifact_registry_repository.google-boa-repository](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/artifact_registry_repository) | data source |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_client_openid_userinfo.me](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |
| [kubectl_path_documents.bankofanthos-manifests](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/path_documents) | data source |
| [kubernetes_service.bankofanthos](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bankofanthos"></a> [bankofanthos](#input\_bankofanthos) | Deploy the Bank of Anthos demo application?  Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_iap"></a> [enable\_iap](#input\_enable\_iap) | Enable Identity-Aware Proxy settings within the project and expose an IAP-protected Ingress | `bool` | `false` | no |
| <a name="input_gcp_gar_service_list"></a> [gcp\_gar\_service\_list](#input\_gcp\_gar\_service\_list) | The list of apis necessary for the project | `list(string)` | <pre>[<br>  "artifactregistry.googleapis.com"<br>]</pre> | no |
| <a name="input_gcp_gke_service_list"></a> [gcp\_gke\_service\_list](#input\_gcp\_gke\_service\_list) | The list of apis necessary for the project | `list(string)` | <pre>[<br>  "cloudresourcemanager.googleapis.com",<br>  "compute.googleapis.com",<br>  "container.googleapis.com",<br>  "iam.googleapis.com"<br>]</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project to deploy resources in | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Default region to use for resources | `string` | `"us-central1"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Default zone to use for resources | `string` | `"us-central1-b"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aoss-java-repository-uri"></a> [aoss-java-repository-uri](#output\_aoss-java-repository-uri) | n/a |
| <a name="output_aoss-python-repository-uri"></a> [aoss-python-repository-uri](#output\_aoss-python-repository-uri) | n/a |
| <a name="output_bankofanthos-frontend"></a> [bankofanthos-frontend](#output\_bankofanthos-frontend) | n/a |
| <a name="output_boa-repository-uri"></a> [boa-repository-uri](#output\_boa-repository-uri) | n/a |
| <a name="output_gke-project-01-cluster-01-kubectl-command"></a> [gke-project-01-cluster-01-kubectl-command](#output\_gke-project-01-cluster-01-kubectl-command) | Outputs |
