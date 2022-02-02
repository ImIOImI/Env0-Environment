output "templates" {
  value = env0_template.template[*]
}

output "environments" {
  value = env0_environment.example[*]
}
