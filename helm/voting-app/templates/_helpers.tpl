{{- define "voting.labels" -}}
app.kubernetes.io/name: voting-app
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
{{- end }}

{{/* usage: include "voting.image" (list $ "example-voting-app-vote") */}}
{{- define "voting.image" -}}
{{- $root := index . 0 -}}
{{- $name := index . 1 -}}
{{- printf "%s/%s:%s" (required "image.registry is required, e.g. --set image.registry=ghcr.io/<owner>" $root.Values.image.registry) $name $root.Values.image.tag -}}
{{- end }}

{{/* database settings shared by result and worker; the password comes from a Secret */}}
{{- define "voting.dbEnv" -}}
- name: POSTGRES_HOST
  value: db
- name: POSTGRES_USER
  value: {{ .Values.db.user | quote }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.db.existingSecret }}
      key: {{ .Values.db.secretKey }}
{{- end }}
