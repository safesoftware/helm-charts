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