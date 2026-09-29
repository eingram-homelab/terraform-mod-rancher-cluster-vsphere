# Terraform Rancher Cluster for vSphere

This module provisions a Rancher-managed RKE2 cluster on vSphere. It creates a Rancher vSphere cloud credential, separate vSphere machine configurations for control-plane and worker nodes, and a Rancher cluster with the requested machine pools.

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.14.0` |
| `rancher/rancher2` provider | `~> 3.0` |

Configure the `rancher2` provider in the calling root module and pass it to this module. The module exposes `rancher_api_url`, `rancher_access_key`, `rancher_secret_key`, and `rancher_insecure` as inputs, but the current module resources do not use those variables to configure the provider.

## Usage

The example assumes the root module has variables for credentials and vSphere settings. Keep secrets in a secure variable source rather than committing them to version control.

```hcl
provider "rancher2" {
	api_url   = var.rancher_api_url
	token_key = "${var.rancher_access_key}:${var.rancher_secret_key}"
	insecure  = var.rancher_insecure
}

module "rancher_cluster" {
	source = "../terraform-mod-rancher-cluster-vsphere"

	providers = {
		rancher2 = rancher2
	}

	rancher_api_url               = var.rancher_api_url
	rancher_access_key            = var.rancher_access_key
	rancher_secret_key            = var.rancher_secret_key
	rancher_insecure              = var.rancher_insecure
	cluster_name                  = "example-cluster"
	kubernetes_version            = "v1.31.4+rke2r1"
	vsphere_cloud_credential_name = "vsphere"
	vsphere_tags                  = ["kubernetes"]

	control_plane_node_count = 3
	control_plane_cpu        = 4
	control_plane_memory     = 8192
	control_plane_disk_size  = 102400
	worker_node_count        = 3
	worker_cpu               = 4
	worker_memory            = 8192
	worker_disk_size         = 102400

	vsphere_datacenter   = "/Datacenter"
	vsphere_datastore    = "/Datacenter/datastore/Datastore"
	vsphere_folder       = "/Datacenter/vm/Kubernetes"
	vsphere_network      = ["/Datacenter/network/VM Network"]
	vsphere_resource_pool = "/Datacenter/host/Cluster/Resources"
	vsphere_template     = "/Datacenter/vm/Templates/Rocky9"
	vsphere_username     = var.vsphere_username
	vsphere_password     = var.vsphere_password
	vsphere_vcenter      = var.vsphere_vcenter

	disabled_features = ["servicelb", "traefik"]
	salt_password     = var.salt_password
	ssh_key           = var.ssh_key
}
```

Set a node count to `0` to omit that machine pool. Optional RKE2 settings such as TLS SANs and component arguments can be supplied through the corresponding variables below.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `rancher_api_url` | `string` | Required | Rancher API URL. Exposed as an input but not currently used by module resources. |
| `rancher_access_key` | `string` | Required | Rancher access key. Exposed as an input but not currently used by module resources. |
| `rancher_secret_key` | `string` | Required, sensitive | Rancher secret key. Exposed as an input but not currently used by module resources. |
| `rancher_insecure` | `bool` | `false` | Whether the Rancher provider should skip TLS verification. Exposed as an input but not currently used by module resources. |
| `cluster_name` | `string` | Required | Name of the Rancher cluster. |
| `kubernetes_version` | `string` | Required | Kubernetes/RKE2 version for the cluster. |
| `vsphere_cloud_credential_name` | `string` | Required | Name of the Rancher vSphere cloud credential. |
| `vsphere_tags` | `list(string)` | Required | Tags applied to the vSphere machines. |
| `control_plane_node_count` | `number` | Required | Number of control-plane and etcd nodes. A value of `0` omits the control-plane pool. |
| `control_plane_cpu` | `number` | Required | vCPU count for each control-plane node. |
| `control_plane_memory` | `number` | Required | Memory in MB for each control-plane node. |
| `control_plane_disk_size` | `number` | Required | Disk size in MB for each control-plane node. |
| `worker_node_count` | `number` | Required | Number of worker nodes. A value of `0` omits the worker pool. |
| `worker_cpu` | `number` | Required | vCPU count for each worker node. |
| `worker_memory` | `number` | Required | Memory in MB for each worker node. |
| `worker_disk_size` | `number` | Required | Disk size in MB for each worker node. |
| `vsphere_datacenter` | `string` | Required | vSphere datacenter path. |
| `vsphere_datastore` | `string` | Required | vSphere datastore path. |
| `vsphere_folder` | `string` | Required | vSphere VM folder path. |
| `vsphere_network` | `list(string)` | Required | vSphere network path(s) for the machines. |
| `vsphere_resource_pool` | `string` | Required | vSphere resource pool path. |
| `vsphere_template` | `string` | Required | vSphere template used to clone the nodes. |
| `vsphere_username` | `string` | Required | Username for the vSphere cloud credential. |
| `vsphere_password` | `string` | Required, sensitive | Password for the vSphere cloud credential. |
| `vsphere_vcenter` | `string` | Required | vCenter server address. |
| `disabled_features` | `list(string)` | Required | RKE2 features to disable. |
| `vsphere_cfgparam` | `list(string)` | `[]` | Additional vSphere VM configuration parameters. |
| `salt_password` | `string` | Required, sensitive | Password value rendered into the node cloud-init configuration. |
| `ssh_key` | `string` | Required | SSH public key added to the configured node accounts. |
| `tls_san` | `list(string)` | `[]` | Additional TLS certificate Subject Alternative Names. |
| `serialize_image_pulls` | `bool` | `false` | Whether Kubernetes image pulls are serialized. |
| `kubelet_arg` | `list(string)` | `[]` | Additional kubelet arguments. |
| `kube_apiserver_arg` | `list(string)` | `[]` | Additional kube-apiserver arguments. |
| `etcd_arg` | `list(string)` | `[]` | Additional etcd arguments. |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `cluster_name` | Rancher cluster name. | No |
| `cluster_id` | Rancher cluster ID. | No |
| `cluster_kube_config` | Cluster kubeconfig. | Yes |
| `cluster_rke_config` | Cluster RKE configuration. | No |