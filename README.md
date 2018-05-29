# Official helm charts of Safe Software

## Configuration

Add the Safe Software charts repository:  
`helm repo add safesoftware https://safesoftware.github.io/helm-charts/`

## Development

### How to build a new chart version (usually done by CI)

```console
helm package chart-source/fmeserver/
mv fmeserver-0.1.0.tgz docs/fmeserver-0.1.0.tgz
helm repo index docs --url https://safesoftware.github.io/helm-charts
```

### Run unit tests

1. `helm plugin install https://github.com/lrills/helm-unittest`
2. `helm unittest <path/to/chart/source>`