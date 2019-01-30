{{/* Generates shared ingress annotations */}}
{{- define "fmeserver.ingress.annotations" }}
kubernetes.io/ingress.class: "nginx"
nginx.ingress.kubernetes.io/proxy-body-size: "0"
nginx.ingress.kubernetes.io/affinity: cookie
nginx.ingress.kubernetes.io/session-cookie-name: {{ .Release.Name }}-ingress
nginx.ingress.kubernetes.io/session-cookie-hash: md5
{{- if (and (not (empty .Values.deployment.certManager.issuerName)) (eq .Values.deployment.certManager.issuerType "cluster")) }}
certmanager.k8s.io/cluster-issuer: {{ .Values.deployment.certManager.issuerName | quote }}
{{- end }}
{{- if (and (not (empty .Values.deployment.certManager.issuerName)) (eq .Values.deployment.certManager.issuerType "namespace")) }}
certmanager.k8s.io/issuer: {{ .Values.deployment.certManager.issuerName | quote }}
{{- end }}
{{- end }}

{{/* Generates ingress tls configuration  */}}
{{- define "fmeserver.ingress.tls" }}
  tls:
    - hosts:
        - {{ .Values.deployment.hostname }}
      {{- if .Values.deployment.tlsSecretName }}
      secretName: {{ .Values.deployment.tlsSecretName }}
      {{- end }}
{{- end }}

{{/* Common labels */}}
{{- define "fmeserver.common.labels" }}
safe.k8s.fmeserver.build: {{ required "A published fmeserver.buildNr needs to be passed in." .Values.fmeserver.buildNr | quote }}
{{- end}}

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
