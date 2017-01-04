# fluentd-k8s-azure [DRAFT]
Fluentd docker image that fetch kubernetes logs and send them 
to azure log analytics.
Required [Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-get-started)

##Configuration 
This image is configure with following environment's variables.

###Mandatory
#####AZURE_WORKSPACE_ID
Your Operations Management Suite workspace ID
#####AZURE_SHARED_KEY
The primary or the secondary Connected Sources client authentication key

###Optionnal
#####FLUENTD_LOG_LEVEL
Define fluentd global log level.
By default set to 'info'
######Values 
["fatal", "error", "warn", "info", "debug", "trace"]

#####KUBERNETES_LOG_LEVEL
Define kubernetes rules log level
By default set to 'info'
######Values 
["fatal", "error", "warn", "info", "debug", "trace"]

##Tasks
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
##k8s
k8s directory contain kubernetes configuration files in order to deploy this image on kubernetes clusters.
####Step 1: Create azure credentials
Based on k8s/secrets-template.yaml, you must create a new k8s/secret.yml
With good values
Then you can execute following command to:
Create secrets
```kubectl create -f k8s/secrets-template.yaml```
Update secrets
```kubectl apply -f k8s/secrets-template.yaml```

####Step 2: Create fluent service account:
Run:
```kubectl create -f k8s/serviceaccount.yml```

####Step 3: Create fluent daemonset
Run:
```kubectl create -f k8s/daemonset.yml```
__! You may want to update fluent docker image tag__
__! You may want to change variables__
