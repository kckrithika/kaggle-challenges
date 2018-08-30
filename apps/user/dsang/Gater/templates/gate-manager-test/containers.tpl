{{- define "containers.args" -}}
{{- if eq . "gate-manager-test"}}
      - --server.port=9090
      - --logging.level.com.zaxxer.hikari=debug
      - --spring.datasource.hikari.maximumPoolSize=6
      - --spring.datasource.hikari.minimumIdle=5
      - --spring.datasource.hikari.leakDetectionThreshold=2000
      - --gater-service.thread.pool.max-size=0
{{- else if eq . "gate-manager-test-tnrp"}}
      - --server.port=9090
      - --scone.srpc.announcing-enabled=false
{{- end -}}
{{- end -}}