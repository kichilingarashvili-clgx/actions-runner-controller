gcloud container clusters get-credentials clgx-gke-cots-us-c1-sbx --region us-central1 --project clgx-anthos-cots-sbx-a799

CONTROLLER_NAMESPACE="arc-systems"

kubectl delete clusterrolebinding arc-gha-rs-controller
kubectl delete clusterrole arc-gha-rs-controller

helm install arc \
    --namespace "${CONTROLLER_NAMESPACE}" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller


    -f  ~/dev/current/actions/actions-runner-controller/corelogic/gha-runner-scale-set-controller/values.yaml

helm list -A | grep arc
kubectl get pods -n "${CONTROLLER_NAMESPACE}"
kubectl get serviceAccounts -n "${CONTROLLER_NAMESPACE}"
kubectl get deployments -n "${CONTROLLER_NAMESPACE}"
kubectl rollout restart deployment arc-gha-rs-controller -n "${CONTROLLER_NAMESPACE}"
kubectl logs pod/arc-gha-rs-controller-697d68c85f-jtq27 -n "${CONTROLLER_NAMESPACE}"
kubectl exec -it arc-gha-rs-controller-697d68c85f-jtq27 -n "${CONTROLLER_NAMESPACE}" -- /bin/bash

INSTALLATION_NAME="arc-runner-set-1"
SCALE_SET_1_NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/corelogic-private/technology_ops_us-smartops-genai_bot"
GITHUB_CONFIG_SECRET_NAME="arc-runner-set-1-github-token"

kubectl create namespace "${SCALE_SET_1_NAMESPACE}"
kubectl delete secret "${GITHUB_CONFIG_SECRET_NAME}" -n "${SCALE_SET_1_NAMESPACE}"
kubectl create secret generic "${GITHUB_CONFIG_SECRET_NAME}" \
    --namespace "${SCALE_SET_1_NAMESPACE}" \
    --from-literal=github_token="${GITHUB_PAT}"

kubectl get secrets -n "${SCALE_SET_1_NAMESPACE}"
kubectl describe secret "${GITHUB_CONFIG_SECRET_NAME}" -n "${SCALE_SET_1_NAMESPACE}"
kubectl get secret "${GITHUB_CONFIG_SECRET_NAME}" -n "${SCALE_SET_1_NAMESPACE}" -o json | jq '.data | map_values(@base64d)'

helm install "${INSTALLATION_NAME}" \
    --namespace "${SCALE_SET_1_NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret="${GITHUB_CONFIG_SECRET_NAME}" \
    --set maxRunners=10 \
    --set minRunners=2 \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set


helm install "${INSTALLATION_NAME}" \
    --namespace "${SCALE_SET_1_NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret.github_token="${GITHUB_PAT}" \
    --set maxRunners=10 \
    --set minRunners=2 \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

kubectl get all -n "${SCALE_SET_1_NAMESPACE}"
kubectl get pods -n "${SCALE_SET_1_NAMESPACE}"
kubectl get deployments -n "${SCALE_SET_1_NAMESPACE}"

# troubleshooting
kubectl logs pod/arc-gha-rs-controller-764f888fc7-rscgl -n arc-systems

# update
helm upgrade "${INSTALLATION_NAME}" \
    --namespace "${SCALE_SET_1_NAMESPACE}" \
    --debug \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret="${GITHUB_CONFIG_SECRET_NAME}" \
    --set maxRunners=10 \
    --set minRunners=2 \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
    

    -f ~/dev/current/actions/actions-runner-controller/corelogic/gha-runner-scale-set-1/values.yaml \

helm uninstall "${INSTALLATION_NAME}" \
    --namespace "${SCALE_SET_1_NAMESPACE}"