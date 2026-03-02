provider "aws" {
  alias  = "tokyo"
  region = var.aws_region_tokyo

  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "virginia"
  region = var.aws_region_virginia

  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}
