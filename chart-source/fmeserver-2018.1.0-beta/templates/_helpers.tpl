{{/* Generates shared ingress annotations */}}
{{- define "fmeserver.ingress.annotations" }}
kubernetes.io/ingress.class: "nginx"
nginx.ingress.kubernetes.io/proxy-body-size: "0"
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

{{/* NFS name */}}
{{- define "nfs-provisioner.fullName" }}
{{- printf "%s-fmeserverdata-nfs" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/* NFS provisioner name */}}
{{- define "nfs-provisioner.provisionerName" -}}
safe.k8s.fmeserver/{{ template "nfs-provisioner.fullName" . -}}
{{- end -}}

{{/* Data volume ClaimName name */}}
{{- define "fmeserver.storage.data.claimName" -}}
{{- if .Values.storage.deployNFS }}
{{- "fmeserver-data-nfs" }}
{{- else }}
{{- "fmeserver-data" }}
{{- end }}
{{- end -}}

{{/* Affinity rules for ReadWriteOnce data disks */}}
{{- define "fmeserver.deployment.dataVolumeAffinity" }}
{{- if not .Values.storage.deployNFS }}
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