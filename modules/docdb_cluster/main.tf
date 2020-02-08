resource "aws_docdb_subnet_group" "docdb" {
  name       = "${var.name}_docdb"
  subnet_ids = var.subnets
}

resource "aws_docdb_cluster_instance" "docdb" {
  count              = 2
  identifier         = "${aws_docdb_cluster.docdb.id}-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.r5.large"
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier     = "${var.name}-docdb"
  db_subnet_group_name   = aws_docdb_subnet_group.docdb.name
  vpc_security_group_ids = var.security_group_ids
  master_username        = var.master_username
  master_password        = var.master_password
  skip_final_snapshot    = true
}

