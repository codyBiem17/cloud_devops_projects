instance_type = "t2.micro"

vpc_cidr = "172.31.0.0/16"

pub_subnet_cidr = "172.31.1.0/24"

priv_subnet_cidr = ["172.31.5.0/24", "172.31.3.0/24"]

db_storage = 20
db_master_username = "biem"
db_name = "rds_wordpress_db"
db_engine = "mysql"
db_engine_version = "8.0.35"
db_instance_class = "db.t3.micro"
db_param_group_name = "default.mysql8.0"

