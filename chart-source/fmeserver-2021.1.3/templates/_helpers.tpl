{{/* Generates shared ingress annotations */}}
{{- define "fmeserver.ingress.annotations" }}
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
{{- define "fmeserver.ingress.tls" }}
{{- if not .Values.deployment.disableTLS }}
  tls:
    - hosts:
        - {{ .Values.deployment.hostname }}
      {{- if .Values.deployment.tlsSecretName }}
      secretName: {{ .Values.deployment.tlsSecretName }}
      {{- end }}
{{- end }}
{{- end }}


{{- define "fmeserver.deployment.protocol" }}
{{- if .Values.deployment.disableTLS }}http{{- else }}https{{- end }}
{{- end }}

{{/* Common labels */}}
{{- define "fmeserver.common.labels" }}
app: {{ template "fmeserver.name" . }}
chart: {{ template "fmeserver.chart" . }}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
{{- if .Values.fmeserver.buildNr }}
safe.k8s.fmeserver.build: {{ .Values.fmeserver.buildNr | quote }}
{{- else }}
safe.k8s.fmeserver.build: {{ .Values.fmeserver.image.tag | quote }}
{{- end }}
{{- end }}

{{/* Data volume ClaimName name */}}
{{- define "fmeserver.storage.data.claimName" -}}
{{- "fmeserver-data" }}
{{- end -}}

{{/* Affinity rules for ReadWriteOnce data disks */}}
{{- define "fmeserver.deployment.dataVolumeAffinity" }}
{{- if ne .Values.storage.fmeserver.accessMode "ReadWriteMany" }}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: safe.k8s.fmeserver.component
        operator: In
        values:
        - core
    topologyKey: "kubernetes.io/hostname"
{{- end}}
{{- end }}

{{/* Create Postgresql hostname */}}
{{- define "fmeserver.database.host" -}}
{{- if .Values.fmeserver.database.host -}}
{{ .Values.fmeserver.database.host -}}
{{- else -}}
{{- printf "%s-postgresql.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/* Create Postgresql admin user password secret */}}
{{- define "fmeserver.database.adminPasswordSecret" -}}
{{- if .Values.fmeserver.database.adminPasswordSecret -}}
{{ .Values.fmeserver.database.adminPasswordSecret }}
{{- else -}}
{{- printf "%s-postgresql" .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "fmeserver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fmeserver.fullname" -}}
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
{{- define "fmeserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the fmeserver database password secret.
*/}}
{{- define "fmeserver.database.secretName" -}}
{{- if .Values.fmeserver.database.passwordSecret -}}
{{ .Values.fmeserver.database.passwordSecret }}
{{- else -}}
{{- printf "%s" (include "fmeserver.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Set the image parameters. We still support the old parameters for now
*/}}
{{- define "fmeserver.image.tag" }}
{{- if .Values.fmeserver.buildNr -}}
{{ .Values.fmeserver.buildNr }}
{{- else -}}
{{ .Values.fmeserver.image.tag }}
{{- end -}}
{{/* Check to make sure exactly one is set */}}
{{- if not .Values.fmeserver.buildNr }}
{{- if not .Values.fmeserver.image.tag }}
{{ fail "fmeserver.image.tag is required." }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
We have to do this double 'if' check to see if the parent value exists otherwise we get
templating errors.
See https://github.com/helm/helm/issues/3708
*/}}
{{- define "fmeserver.image.registry" }}
{{- if .Values.images -}}
{{- if .Values.images.registry -}}
{{ .Values.images.registry }}
{{- else -}}
{{ .Values.fmeserver.image.registry }}
{{- end -}}
{{- else -}}
{{ .Values.fmeserver.image.registry }}
{{- end -}}
{{- end -}}

{{- define "fmeserver.image.namespace" }}
{{- if .Values.images -}}
{{- if .Values.images.namespace -}}
{{ .Values.images.namespace }}
{{- else -}}
{{ .Values.fmeserver.image.namespace }}
{{- end -}}
{{- else -}}
{{ .Values.fmeserver.image.namespace }}
{{- end -}}
{{- end -}}

{{- define "fmeserver.image.pullPolicy" }}
{{- if .Values.images -}}
{{- if .Values.images.pullPolicy -}}
{{ .Values.images.pullPolicy }}
{{- else -}}
{{ .Values.fmeserver.image.pullPolicy }}
{{- end -}}
{{- else -}}
{{ .Values.fmeserver.image.pullPolicy }}
{{- end -}}
{{- end -}}

{{- define "fmeserver.resources.web" }}
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

{{- define "fmeserver.healthcheck.url" }}
{{- if .Values.fmeserver.healthcheck.simple -}}
/fmerest/v3/healthcheck/simple
{{- else -}}
/fmerest/v3/healthcheck?ready=true
{{- end -}}
{{- end -}}

{{- define "fmeserver.liveness.url" }}
{{- if .Values.fmeserver.healthcheck.simple -}}
/fmerest/v3/healthcheck/simple
{{- else -}}
/fmerest/v3/healthcheck?ready=false
{{- end -}}
{{- end -}}

{{- define "fmeserver.ingress.apiversion" }}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
networking.k8s.io/v1
{{- else -}}
extensions/v1beta1
{{- end -}}
{{- end -}}

{{- define "fmeserver.ingress.web.service" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
service:
  name: fmeserverweb
  port:
    number: 8080
{{- else -}}
serviceName: fmeserverweb
servicePort: 8080
{{- end -}}
{{- end -}}

{{- define "fmeserver.ingress.websocket.service" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
service:
  name: fmeserverwebsocket
  port:
    number: 7078
{{- else -}}
serviceName: fmeserverwebsocket
servicePort: 7078
{{- end -}}
{{- end -}}

{{- define "fmeserver.ingress.pathType" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
pathType: Prefix
{{- end -}}
{{- end -}}
