# README
This Fluentd docker image fetch kubernetes logs and based on pod labels either send them on azure log analytics either on a local directory.

```
+--------------------------------------------------------------+
| K8s Agent:                                                   |
|                                            +------------+    |
|                                            |Container_A |    |
|                                            |            |    |
| Agent Filesystem:                          +---------+--+    |
| +--------------------+      <send_logs_to            |       |
| |/var/log/containers |<------------------------------+       |
| +----------+---------+                               |       |
|            |                               +---------+--+    |
|            |                               |Container_B |    |
| Fetch_logs |                               |            |    |
|            v                               +------------+    |         +--------------------+
|      +----------+    apply_rule_1_stream_logs_to --------------------->| Azure LogAnalytics |
|      |Fluentd   +-------------------------------/     /      |         +--------------------+
|      |Container +-------------------------------------\      |         +--------------------+
|      +----------+   apply_rule_0_archive_logs_to --------------------->| Azure Blob Storage |
|                                                              |         +--------------------+
+--------------------------------------------------------------+
```

## Requirements
* [Kubernetes cluster](https://kubernetes.io/docs/getting-started-guides/azure)

* [Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-get-started)

## Configuration
### Volumes
* /var/log/containers  

  This directory must be mounted from kubernetes node and contains containers's logs.  
  This volume should be mounted with READ only permission.  
  ```mount /var/log/containers -> /var/log/containers```

* /var/lib/docker/containers

  This directory contain additionnal docker's informations.  
  Required by plugin: 'fluent-plugin-kubernetes_metadata_filter'.   
  Should be mounted with READ only permission.  
  ``` mount /var/lib/docker/containers -> /var/lib/docker/containers ```

* /fluentd/log   

  This directory contain logs that need to be archived after being processed by fluentd.  
  It should be a blob storage shared with all fluentd instances.  
  __! Blob storage is not configured inside the container but must be mounted as a volume__  
  ``` mount blob_storage /fluentd/log ```

### Variables
This image is configured following environment's variables.

* AZURE_WORKSPACE_ID

  Your Operations Management Suite workspace ID 

* AZURE_SHARED_KEY

  The primary or the secondary Connected Sources client authentication key

* FLUENTD_LOG_LEVEL

  Define fluentd global log level.
  By default set to 'info'
  Accept: ["fatal", "error", "warn", "info", "debug", "trace"]

* KUBERNETES_LOG_LEVEL

  Define kubernetes rules log level
  By default set to 'info'
  Accept: ["fatal", "error", "warn", "info", "debug", "trace"]

## Tasks

A Rakefile define common operations for this project.
Like build, test or publish to docker hub

Run ```rake -T``` for more informations.  
Output example:

```
    rake build            # Build Docker Image olblak/fluentd-k8s-azure:0.4.0
    rake clean            # Remove docker olblak/fluentd-k8s-azure:0.4.0
    rake init             # Install gem dependencies for tests
    rake publish          # Publish olblak/fluentd-k8s-azure:0.4.0 to DockerHub
    rake run              # Run Docker Image olblak/fluentd-k8s-azure:0.4.0
    rake shell            # Run Docker Image olblak/fluentd-k8s-azure:0.4.0 with shell
    rake test             # Run all spec files
    rake test:container   # Run Container tests for olblak/fluentd-k8s-azure:0.4.0
    rake test:dockerfile  # Run Dockerfile tests for olblak/fluentd-k8s-azure:0.4.0
```
