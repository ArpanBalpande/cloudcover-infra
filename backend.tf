terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "CloudCoverTest"

    workspaces {
      name = "cloudcover-infra"
    }
  }
}