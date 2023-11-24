{{/* Generates shared ingress annotations */}}
{{- define "fmeflow.ingress.annotations" }}
{{- if (and (not (empty .Values.deployment.certManager.issuerName)) (eq .Values.deployment.certManager.issuerType "cluster")) }}
certmanager.k8s.io/cluster-issuer: {{ .Values.deployment.certManager.issuerName | quote }}
cert-manager.io/cluster-issuer: {{ .Values.deployment.certManager.issuerName | quote }}
{{- end }}
{{- if (and (not (empty .Values.deployment.certManager.issuerName)) (eq .Values.deployment.certManager.issuerType "namespace")) }}
certmanager.k8s.io/issuer: {{ .Values.deployment.certManager.issuerName | quote }}
cert-manager.io/issuer: {{ .Values.deployment.certManager.issuerName | quote }}
{{- end }}
{{- end }}

{{/* Generates ingress tls configuration  */}}
{{- define "fmeflow.ingress.tls" }}
{{- if not .Values.deployment.disableTLS }}
  tls:
    - hosts:
        - {{ .Values.deployment.hostname }}
      {{- if .Values.deployment.tlsSecretName }}
      secretName: {{ .Values.deployment.tlsSecretName }}
      {{- end }}
{{- end }}
{{- end }}


{{- define "fmeflow.deployment.protocol" }}
{{- if .Values.deployment.disableTLS }}http{{- else }}https{{- end }}
{{- end }}

{{/* Common labels */}}
{{- define "fmeflow.common.labels" }}
app: {{ template "fmeflow.name" . }}
chart: {{ template "fmeflow.chart" . }}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
safe.k8s.fmeflow.build: {{ .Values.fmeflow.image.tag | quote }}
{{- end }}

{{/* Data volume ClaimName name */}}
{{- define "fmeflow.storage.data.claimName" -}}
{{- "fmeflow-data" }}
{{- end -}}

{{/* Affinity rules for ReadWriteOnce data disks */}}
{{- define "fmeflow.deployment.dataVolumeAffinity" }}
{{- if ne .Values.storage.fmeflow.accessMode "ReadWriteMany" }}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: safe.k8s.fmeflow.component
        operator: In
        values:
        - core
    topologyKey: "kubernetes.io/hostname"
{{- end}}
{{- end }}

{{/* Create Postgresql hostname */}}
{{- define "fmeflow.database.host" -}}
{{- if .Values.fmeflow.database.host -}}
{{ .Values.fmeflow.database.host -}}
{{- else -}}
{{- printf "%s-postgresql.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/* Create Postgresql admin user password secret */}}
{{- define "fmeflow.database.adminPasswordSecret" -}}
{{- if .Values.fmeflow.database.adminPasswordSecret -}}
{{ .Values.fmeflow.database.adminPasswordSecret }}
{{- else -}}
{{- printf "%s-postgresql" .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "fmeflow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fmeflow.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fmeflow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the fmeflow database password secret.
*/}}
{{- define "fmeflow.database.secretName" -}}
{{- if .Values.fmeflow.database.passwordSecret -}}
{{ .Values.fmeflow.database.passwordSecret }}
{{- else -}}
{{- printf "%s" (include "fmeflow.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Set the image parameters.
*/}}
{{- define "fmeflow.image.tag" }}
{{- .Values.fmeflow.image.tag }}
{{/* Check to make sure exactly one is set */}}
{{- if not .Values.fmeflow.image.tag }}
{{ fail "fmeflow.image.tag is required." }}
{{- end -}}
{{- end -}}

{{/*
We have to do this double 'if' check to see if the parent value exists otherwise we get
templating errors.
See https://github.com/helm/helm/issues/3708
*/}}
{{- define "fmeflow.image.registry" }}
{{- if .Values.images -}}
{{- if .Values.images.registry -}}
{{ .Values.images.registry }}
{{- else -}}
{{ .Values.fmeflow.image.registry }}
{{- end -}}
{{- else -}}
{{ .Values.fmeflow.image.registry }}
{{- end -}}
{{- end -}}

{{- define "fmeflow.image.namespace" }}
{{- if .Values.images -}}
{{- if .Values.images.namespace -}}
{{ .Values.images.namespace }}
{{- else -}}
{{ .Values.fmeflow.image.namespace }}
{{- end -}}
{{- else -}}
{{ .Values.fmeflow.image.namespace }}
{{- end -}}
{{- end -}}

{{- define "fmeflow.image.pullPolicy" }}
{{- if .Values.images -}}
{{- if .Values.images.pullPolicy -}}
{{ .Values.images.pullPolicy }}
{{- else -}}
{{ .Values.fmeflow.image.pullPolicy }}
{{- end -}}
{{- else -}}
{{ .Values.fmeflow.image.pullPolicy }}
{{- end -}}
{{- end -}}

{{- define "fmeflow.resources.web" }}
{{- if .Values.resources.web }}
{{- if .Values.resources.web.requests }}
requests:
{{ .Values.resources.web.requests | toYaml | indent 2 -}}
{{- end }}
{{- if or .Values.resources.web.limits.cpu .Values.resources.web.limits.memory }}
limits:
{{- if .Values.resources.web.limits.cpu }}
  cpu: {{ .Values.resources.web.limits.cpu }}
{{- end }}
{{- if .Values.resources.web.limits.memory }}
  memory: {{ .Values.resources.web.limits.memory }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "fmeflow.healthcheck.url" -}}
/fmeapiv4/healthcheck/readiness
{{- end -}}

{{- define "fmeflow.liveness.url" -}}
/fmeapiv4/healthcheck/liveness
{{- end -}}

{{- define "fmeflow.ingress.apiversion" }}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
networking.k8s.io/v1
{{- else -}}
extensions/v1beta1
{{- end -}}
{{- end -}}

{{- define "fmeflow.ingress.web.service" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
service:
  name: fmeflowweb
  port:
    number: 8080
{{- else -}}
serviceName: fmeflowweb
servicePort: 8080
{{- end -}}
{{- end -}}

{{- define "fmeflow.ingress.websocket.service" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
service:
  name: fmeflowwebsocket
  port:
    number: 7078
{{- else -}}
serviceName: fmeflowwebsocket
servicePort: 7078
{{- end -}}
{{- end -}}

{{- define "fmeflow.ingress.pathType" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
pathType: Prefix
{{- end -}}
{{- end -}}

{{- define "fmeflow.pdb.apiversion" }}
{{- if semverCompare ">=1.21-0" .Capabilities.KubeVersion.Version -}}
policy/v1
{{- else -}}
policy/v1beta1
{{- end -}}
{{- end -}}
