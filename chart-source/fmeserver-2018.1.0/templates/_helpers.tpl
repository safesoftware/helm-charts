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