#!/bin/sh

# Check if azure variables are define
: "${AZURE_WORKSPACE_ID?'Require AZURE_WORKSPACE_ID'}"
: "${AZURE_SHARED_KEY?'Require AZURE_SHARED_KEY'}"

# Check fluent-plugin-azurestorage variable
: "${AZURE_ARCHIVE_CONTAINER?'Require AZURE_ARCHIVE_CONTAINER'}"
: "${AZURE_ARCHIVE_STORAGE_ACCESS_KEY?'Require AZURE_ARCHIVE_STORAGE_ACCESS_KEY'}"
: "${AZURE_ARCHIVE_STORAGE_ACCOUNT?'Require AZURE_ARCHIVE_STORAGE_ACCOUNT'}"

FLUENTD_LOG_LEVEL="${FLUENTD_LOG_LEVEL:-info}"
KUBERNETES_LOG_LEVEL="${KUBERNETES_LOG_LEVEL:-info}"

# Update fluentd configuration file
sed -i "s/FLUENTD_LOG_LEVEL/${FLUENTD_LOG_LEVEL}/g" "/fluentd/etc/fluent.conf"
sed -i "s/KUBERNETES_LOG_LEVEL/${KUBERNETES_LOG_LEVEL}/g" "/fluentd/etc/conf.d/kubernetes.conf"

# Configure fluent-plugin-azure-loganalytics
sed -i "s/CUSTOMER_ID/${AZURE_WORKSPACE_ID}/g" "/fluentd/etc/conf.d/kubernetes.conf"
    # Use '#' instead of '/' as '/' is used inside ${AZURE_SHARED_KEY}
sed -i "s#KEY_STRING#${AZURE_SHARED_KEY}#g" "/fluentd/etc/conf.d/kubernetes.conf"

# Configure fluent-plugin-azurestorage 
sed -i "s/AZURE_ARCHIVE_STORAGE_ACCOUNT/${AZURE_ARCHIVE_STORAGE_ACCOUNT}/g" "/fluentd/etc/conf.d/kubernetes.conf"
sed -i "s/AZURE_ARCHIVE_STORAGE_ACCESS_KEY/${AZURE_ARCHIVE_STORAGE_ACCESS_KEY}/g" "/fluentd/etc/conf.d/kubernetes.conf"
sed -i "s/AZURE_ARCHIVE_CONTAINER/${AZURE_ARCHIVE_CONTAINER}/g" "/fluentd/etc/conf.d/kubernetes.conf"

exec fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins ${FLUENTD_OPT}
