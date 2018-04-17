# Official helm charts of Safe Software

## Configuration

Add the Safe Software charts repository:  
`helm repo add safesoftware https://safesoftware.github.io/helm-charts/`

### How to build a new chart version

```console
helm package chart-source/fmeserver/
mv fmeserver-0.1.0.tgz docs/fmeserver-0.1.0.tgz
helm repo index docs --url https://safesoftware.github.io/helm-charts
```