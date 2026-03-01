{{/*
차트 이름. nameOverride가 있으면 사용하고, 없으면 Chart.Name을 사용한다.
*/}}
{{- define "trend-board.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
릴리스 전체 이름. fullnameOverride → Release.Name+Chart.Name 순서로 결정한다.
K8s 리소스 이름 최대 63자 제한(DNS naming spec)을 따른다.
*/}}
{{- define "trend-board.fullname" -}}
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

{{/*
차트 이름+버전. 라벨에 사용한다.
*/}}
{{- define "trend-board.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
공통 라벨. 모든 리소스의 metadata.labels에 포함한다.
*/}}
{{- define "trend-board.labels" -}}
helm.sh/chart: {{ include "trend-board.chart" . }}
{{ include "trend-board.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
part-of: dealspot
component: backend-server
{{- end }}

{{/*
셀렉터 라벨. Deployment.spec.selector와 Service.spec.selector에 사용한다.
*/}}
{{- define "trend-board.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trend-board.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
