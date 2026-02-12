# consul_server.hcl
datacenter = "dc1"
data_dir = "/opt/consul"

# Настройка сервера
server = true
bootstrap_expect = 1

# UI включен
ui = true

# Сетевые настройки
bind_addr = "0.0.0.0"
advertise_addr = "192.168.94.209"
client_addr = "0.0.0.0"

# Порт для UI
ports {
  http = 8500
  https = -1
  grpc = 8502
  serf_lan = 8301
  serf_wan = 8302
  server = 8300
  dns = 8600
}

# Включить Connect для Service Mesh
connect {
  enabled = true
}

# Настройки производительности
performance {
  raft_multiplier = 1
}

# Автоматическая настройка ретраев
retry_join = []

# Логи
log_level = "INFO"
enable_syslog = false