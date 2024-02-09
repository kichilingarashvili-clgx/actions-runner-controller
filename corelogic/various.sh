helm list -A | grep arc
kubectl get pods -n arc-systems
kubectl logs pod/arc-gha-rs-controller-764f888fc7-847q8 -n arc-systems
kubectl logs pod/arc-gha-rs-controller-764f888fc7-847q8 -n arc-systems | grep error