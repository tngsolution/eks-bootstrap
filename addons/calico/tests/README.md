# Calico CNI Tests

Ce répertoire contient des manifests pour tester le CNI Calico et les Network Policies.

## Déploiement des tests

```bash
# Créer les namespaces et déployer les pods
kubectl apply -f namespaces.yaml
kubectl apply -f frontend-pods.yaml
kubectl apply -f backend-pods.yaml

# Attendre que les pods soient prêts
kubectl wait --for=condition=ready pod -l app=frontend -n test-frontend --timeout=60s
kubectl wait --for=condition=ready pod -l app=backend -n test-backend --timeout=60s

# Vérifier les pods et leurs IPs
kubectl get pods -n test-frontend -o wide
kubectl get pods -n test-backend -o wide
```

## Tests de connectivité

### Test 1: Connectivité sans Network Policy

```bash
# Tester la communication frontend -> backend
FRONTEND_POD=$(kubectl get pod -n test-frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}')
BACKEND_IP=$(kubectl get svc backend -n test-backend -o jsonpath='{.spec.clusterIP}')

# Doit fonctionner
kubectl exec -n test-frontend $FRONTEND_POD -- wget -qO- --timeout=2 http://$BACKEND_IP:5678

# Tester la résolution DNS
kubectl exec -n test-frontend $FRONTEND_POD -- nslookup backend.test-backend.svc.cluster.local
```

### Test 2: Appliquer les Network Policies

```bash
# Appliquer les policies
kubectl apply -f network-policy-test.yaml

# Vérifier les policies
kubectl get networkpolicies -n test-backend
kubectl describe networkpolicy allow-frontend-to-backend -n test-backend
```

### Test 3: Valider l'isolation

```bash
# Frontend doit TOUJOURS pouvoir accéder au backend (policy autorise)
kubectl exec -n test-frontend $FRONTEND_POD -- wget -qO- --timeout=2 http://$BACKEND_IP:5678

# Créer un pod test dans un autre namespace (doit être bloqué)
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh -c "wget -qO- --timeout=2 http://$BACKEND_IP:5678"
# Doit timeout car policy deny par défaut
```

## Vérifications Calico

```bash
# Vérifier que Calico gère bien les policies
kubectl get networkpolicies --all-namespaces

# Voir les statistiques Calico (si API server activé)
kubectl get felixconfiguration default -o yaml

# Vérifier les logs calico-node
kubectl logs -n calico-system -l k8s-app=calico-node --tail=50
```

## Nettoyage

```bash
# Supprimer les resources de test
kubectl delete -f network-policy-test.yaml
kubectl delete -f backend-pods.yaml
kubectl delete -f frontend-pods.yaml
kubectl delete -f namespaces.yaml
```

## Résultats attendus

- ✅ Les pods frontend et backend démarrent et obtiennent des IPs
- ✅ Frontend peut résoudre le DNS du backend
- ✅ Frontend peut communiquer avec backend (avec ou sans policy)
- ✅ Un pod externe ne peut PAS communiquer avec backend après application des policies
- ✅ Les Network Policies sont visibles dans `kubectl get networkpolicies`
