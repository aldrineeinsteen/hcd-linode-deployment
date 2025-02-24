resource "kubernetes_namespace" "mission_control" {
  metadata {
    name = var.namespace
  }
  
}

resource "null_resource" "install_kots_cli" {
  provisioner "local-exec" {
    command = <<EOT
    export KOTS_INSTALL_PATH="$(pwd)/bin"
    mkdir -p $KOTS_INSTALL_PATH
    curl -fsSL https://kots.io/install | REPL_INSTALL_PATH=$KOTS_INSTALL_PATH bash
    export PATH=$KOTS_INSTALL_PATH:\$PATH
    EOT
  }
}

resource "null_resource" "install_cert_manager" {
  depends_on = [null_resource.install_kots_cli, kubernetes_namespace.mission_control, local_file.mission_control_config]

  provisioner "local-exec" {
    command = <<EOT
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
    EOT
  }
}

resource "null_resource" "install_kots_admin_console" {
  depends_on = [null_resource.install_kots_cli, kubernetes_namespace.mission_control, local_file.mission_control_config, null_resource.install_cert_manager]

  provisioner "local-exec" {
    command = <<EOT
    kubectl kots install mission-control \
      --namespace "${var.namespace}" \
      --license-file ${var.license_path} \
      --shared-password "${var.shared_password}" \
      --no-port-forward \
      --config-values "${abspath(local_file.mission_control_config.filename)}" \
      --skip-preflights true \
      --wait-duration 5m
    EOT
  }
}
resource "local_file" "mission_control_config" {
  filename = "${path.module}/mission-control-config.yaml"
  content  = <<EOT
apiVersion: kots.io/v1beta1
kind: ConfigValues
metadata:
  name: Mission Control
  namespace: ${var.namespace}
spec:
  values:
    mc_mode:
      value: "control_plane"
    loki_chunks_bucket_name:
      value: "${var.loki_bucket_name}"
    mimir_attached_storage_class:
      value: "linode-block-storage-retain"
    mimir_bucket_name:
      value: "${var.mimir_bucket_name}"
    observability_bucket_backend:
      value: "s3"
    observability_bucket_endpoint:
      value: "${var.s3_endpoint}"
    observability_bucket_region:
      value: "${var.s3_region}"
    observability_bucket_secret_access_key:
      value: "${base64encode(var.s3_secret_key)}"
    observability_enabled:
      default: "1"
    observability_bucket_access_key_id:
      value: "${var.s3_access_key}"
EOT
}

resource "null_resource" "wait_for_mission_control_crds" {
  depends_on = [null_resource.install_kots_admin_console]

  provisioner "local-exec" {
    command = <<EOT
    echo "Waiting for Mission Control CRDs to be available..."
    while ! kubectl get crds | grep missioncontrol.datastax.com; do
      echo "Still waiting for Mission Control CRDs..."
      sleep 10
    done
    echo "Mission Control CRDs are ready."
    EOT
  }
}

resource "local_file" "mission_control_cluster_yaml" {
  filename = "${path.module}/mission-control-cluster.yaml"
  content  = <<EOT
apiVersion: missioncontrol.datastax.com/v1beta2
kind: MissionControlCluster
metadata:
  name: demo
  namespace: demo-mn9zo0t8
spec:
  createIssuer: true
  dataApi:
    enabled: false
  encryption:
    internodeEncryption:
      certs:
        createCerts: true
      enabled: true
  k8ssandra:
    auth: true
    cassandra:
      config:
        cassandraYaml: {}
        dseYaml: {}
        jvmOptions:
          gc: G1GC
          heapSize: 1Gi
      datacenters:
        - config:
            cassandraYaml: {}
            dseYaml: {}
          datacenterName: gb-lon-dc-1
          dseWorkloads:
            graphEnabled: false
            searchEnabled: false
          k8sContext: ''
          metadata:
            name: demo-gb-lon-dc-1
            pods: {}
            services:
              additionalSeedService: {}
              allPodsService: {}
              dcService: {}
              nodePortService: {}
              seedService: {}
          networking: {}
          perNodeConfigMapRef: {}
          racks:
            - name: rk-1
              nodeAffinityLabels: {}
          size: 1
          stopped: false
      resources:
        requests:
          cpu: 1000m
          memory: 4Gi
      serverImage: ''
      serverType: hcd
      serverVersion: 1.1.0
      storageConfig:
        cassandraDataVolumeClaimSpec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 2Gi
          storageClassName: linode-block-storage-retain
      superuserSecretRef:
        name: demo-superuser
EOT
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo-mn9zo0t8"
    
    labels = {
      "mission-control.datastax.com/is-project" = "true"
    }
    
    annotations = {
      "mission-control.datastax.com/project-name" = "demo"
    }
  }
}

resource "null_resource" "apply_mission_control_cluster" {
  depends_on = [null_resource.wait_for_mission_control_crds, local_file.mission_control_cluster_yaml, kubernetes_namespace.demo]

  provisioner "local-exec" {
    command = <<EOT
    kubectl apply -f ${abspath(local_file.mission_control_cluster_yaml.filename)}
    EOT
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

output "namespace" {
  value = kubernetes_namespace.mission_control.metadata.0.name
}