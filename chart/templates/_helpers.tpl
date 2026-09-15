{{- define "everypay.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "everypay.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "everypay.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "everypay.selectorLabels" -}}
app.kubernetes.io/name: {{ include "everypay.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "everypay.labels" -}}
helm.sh/chart: {{ include "everypay.chart" . }}
{{ include "everypay.selectorLabels" . }}
app.kubernetes.io/version: {{ include "everypay.imageTag" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "everypay.imageTag" -}}
{{- .Values.image.tag | default .Chart.AppVersion }}
{{- end }}

{{- define "everypay.image" -}}
{{- printf "%s:%s" .Values.image.repository (include "everypay.imageTag" .) }}
{{- end }}

{{/* Окружение Django: общий ConfigMap + пароли из Secret (оба из ops/) */}}
{{- define "everypay.appEnv" -}}
envFrom:
  - configMapRef:
      name: {{ .Values.configMapName }}
env:
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Values.secretName }}
        key: POSTGRES_PASSWORD
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ .Values.secretName }}
        key: SECRET_KEY
{{- end }}
