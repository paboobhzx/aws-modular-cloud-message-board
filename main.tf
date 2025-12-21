provider "aws" {
    region = "us-east-1"
}

#Calling modules
#1 - Networking
module "networking" {
    source = "./modules/networking"
}
#2 - Database
module "database" {
    source = "./modules/database"
}
#3 - Storage
module "storage" {
    source = "./modules/storage"
}
#4 - Compute - passing outputs from modules as inputs to this module
module "compute" {
    source = "./modules/compute"
    vpc_id = module.networking.vpc_id
    subnet_id = module.networking.public_subnet_id
    db_table_name = module.database.table_name
    db_table_arn = module.database.table_arn 
    
}