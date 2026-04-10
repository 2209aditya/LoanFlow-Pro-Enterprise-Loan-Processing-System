output "aks_name" {
  value = module.aks.aks_name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "redis_hostname" {
  value = module.redis.hostname
}