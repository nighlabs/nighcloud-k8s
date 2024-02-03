# About
This is my cheatsheet of how I tested the Vault Secrets Operator.  It assumes you've created a Project, Application, and Service Principal in HCP Vault Secrets.

## Steps
We'll need to provide an initial secret for the vault secrets operator to be able to authenticate to Vault Secrets in HCP Cloud.

First create a service principal in HCP Vault Secrets and setup env for them (NOTE: turn off shell history... `fp -c` in macos)
```
export HCP_CLIENT_ID=
export HCP_CLIENT_SECRET=
export HCP_ORG_ID=
export HCP_PROJECT_ID=
export APP_NAME=
```

Load the Org ID and Project ID into the Vault Secrets Operator namespace
```
kubectl create -f - <<EOF
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: HCPAuth
metadata:
  name: default
  namespace: vault-secrets-op
spec:
  organizationID: $HCP_ORG_ID
  projectID: $HCP_PROJECT_ID
  servicePrincipal:
    secretRef: vault-secrets-op-sp
EOF
```

Load the secret into the k8s cluster
```
kubectl create secret generic vault-secrets-op-sp \
    --namespace test \
    --from-literal=clientID=$HCP_CLIENT_ID \
    --from-literal=clientSecret=$HCP_CLIENT_SECRET
```

Create a test namespace: `kubectl create namespace test`

Create a test secret sync manifest
```
kubectl create -f - <<EOF
apiVersion: secrets.hashicorp.com/v1beta1
kind: HCPVaultSecretsApp
metadata:
  name: web-application
  namespace: test
spec:
  appName: $APP_NAME
  destination:
    create: true
    labels:
      hvs: "true"
    name: web-application
  refreshAfter: 1h
EOF

```