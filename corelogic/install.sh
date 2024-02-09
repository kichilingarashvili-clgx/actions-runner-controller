gcloud container clusters get-credentials clgx-gke-cots-us-c1-sbx --region us-central1 --project clgx-anthos-cots-sbx-a799

CONTROLLER_NAMESPACE="arc-systems"

helm install arc \
    --namespace "${CONTROLLER_NAMESPACE}" \
    --create-namespace \
    -f  ~/dev/current/actions/actions-runner-controller/corelogic/gha-runner-scale-set-controller/values.yaml \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

helm list -A | grep arc
kubectl get pods -n "${CONTROLLER_NAMESPACE}"
kubectl get serviceAccounts -n "${CONTROLLER_NAMESPACE}"
kubectl get deployments -n "${CONTROLLER_NAMESPACE}"
kubectl rollout restart deployment arc-gha-rs-controller -n "${CONTROLLER_NAMESPACE}"

INSTALLATION_NAME="arc-runner-set-1"
SCALE_SET_1_NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/corelogic-private/technology_ops_us-smartops-genai_bot"
GITHUB_PAT="fake"
GITHUB_CONFIG_SECRET_NAME="arc-runner-set-1-github-token"

kubectl create namespace "${SCALE_SET_1_NAMESPACE}"
kubectl create secret generic "${GITHUB_CONFIG_SECRET_NAME}" \
    --namespace "${SCALE_SET_1_NAMESPACE}" \
    --from-literal=github_token="${GITHUB_PAT}"

kubectl get secrets -n "${SCALE_SET_1_NAMESPACE}"
kubectl describe secret "${GITHUB_CONFIG_SECRET_NAME}" -n "${SCALE_SET_1_NAMESPACE}"

helm install "${INSTALLATION_NAME}" \
    --namespace "${SCALE_SET_1_NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret="${GITHUB_CONFIG_SECRET_NAME}" \
    --set maxRunners=10 \
    --set minRunners=2 \
    -f ~/dev/current/actions/actions-runner-controller/corelogic/gha-runner-scale-set-1/values.yaml \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

kubectl get all -n "${SCALE_SET_1_NAMESPACE}"
kubectl get pods -n "${SCALE_SET_1_NAMESPACE}"
kubectl get deployments -n "${SCALE_SET_1_NAMESPACE}"

# troubleshooting
kubectl logs pod/arc-gha-rs-controller-764f888fc7-rscgl -n arc-systems

# update
helm upgrade "${INSTALLATION_NAME}" \
    --namespace "${SCALE_SET_1_NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret="${GITHUB_CONFIG_SECRET_NAME}" \
    --set maxRunners=10 \
    --set minRunners=2 \
    -f ~/dev/current/actions/actions-runner-controller/corelogic/gha-runner-scale-set-1/values.yaml \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set