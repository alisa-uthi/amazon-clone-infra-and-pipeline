{{/*
Expand the name of the chart.
*/}}
{{- define "amazon-clone-template.name" -}}
{{- default .Chart.Name .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "amazon-clone-template.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "amazon-clone-template.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "amazon-clone-template.labels" -}}
app: {{ include "amazon-clone-template.name" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "amazon-clone-template.selectorLabels" -}}
app: {{ include "amazon-clone-template.name" . }}
{{- end -}}

{{/*
Service Selector labels
*/}}
{{- define "amazon-clone-template.serviceSelectorLabels" -}}
app: {{ include "amazon-clone-template.name" . }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "amazon-clone-template.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "amazon-clone-template.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Container Name
*/}}
{{- define "amazon-clone-template.containerName" -}}
{{ include "amazon-clone-template.fullname" . }}
{{- end -}}

{{/*
Replicas Count
*/}}
{{- define "amazon-clone-template.replicas" -}}
{{- $environment := get .Values.environment .Values.deploymentEnvironment -}}
{{- if hasKey .Values.environment .Values.deploymentEnvironment -}}
    {{ $environment.replicaCount }}
{{- else -}}
    {{ default 1 $environment.defaultReplicas }}
{{- end -}}
{{- end -}}


{{/*
Namespace
*/}}
{{- define "amazon-clone-template.namespace" -}}
{{ .Values.projectName }}
{{- $environment := get .Values.environment .Values.deploymentEnvironment -}}
{{- if $environment.suffixNamespace -}}
-{{ .Values.deploymentEnvironment }}
{{- end -}}
{{- end -}}

{{/*
    Environment UpperCase
*/}}
{{- define "amazon-clone-template.envUppercase" -}}
{{ .Values.deploymentEnvironment | upper }}
{{- end -}}