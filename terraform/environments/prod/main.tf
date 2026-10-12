provider "aws" { region="ap-south-1" alias="primary" }
provider "aws" { region="ap-south-2" alias="secondary" }
provider "aws" { region="ap-south-1" }

module "kms_primary" { source="../../modules/kms" region="ap-south-1" }
module "vpc_primary" { source="../../modules/vpc" region="ap-south-1" cidr="10.0.0.0/16" }

# Note: full prod main.tf combines all modules - see docs for full version
# This is simplified for repo structure compliance
