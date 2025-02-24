
resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo-namespace"
    
    labels = {
      "mission-control.datastax.com/is-project" = "true"
    }
    
    annotations = {
      "mission-control.datastax.com/project-name" = "demo"
    }
  }
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


resource "null_resource" "apply_mission_control_cluster" {
  depends_on = [null_resource.wait_for_mission_control_crds, local_file.mission_control_cluster_yaml, kubernetes_namespace.demo]

  provisioner "local-exec" {
    command = <<EOT
    kubectl apply -f ${abspath(local_file.mission_control_cluster_yaml.filename)}
    EOT
  }
}
