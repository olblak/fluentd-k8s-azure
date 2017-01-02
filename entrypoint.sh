#!/bin/sh

# Check if azure variables are define
: "${AZURE_WORKSPACE_ID?'Require AZURE_WORKSPACE_ID'}"
: "${AZURE_SHARED_KEY?'Require AZURE_SHARED_KEY'}"

# Update fluentd configuration file
sed -i "s/CUSTOMER_ID/${AZURE_WORKSPACE_ID}/g" "/fluentd/etc/conf.d/kubernetes.conf"
    # Use '#' instead of '/' as '/' is used inside ${AZURE_SHARED_KEY}
sed -i "s#KEY_STRING#${AZURE_SHARED_KEY}#g" "/fluentd/etc/conf.d/kubernetes.conf"

exec fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins ${FLUENTD_OPT}
