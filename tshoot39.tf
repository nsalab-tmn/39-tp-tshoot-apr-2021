module "flask-app" {
    source = "./flask-webserver"
}

module "competion" {
    source = "./terraform"
    count = 6
    prefix = format("comp-%02d", count.index+1)
    ts39-api-url = module.flask-app.ts39-api-url
}

output "passwords" {
  value = [ module.competion.*.pass ]
}