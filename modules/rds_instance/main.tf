resource "aws_security_group" "this" {
  name        = "${var.name}-db-access"
  description = "Allow inbound traffic to a DB instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  identifier             = "${var.name}-db-instance"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = var.engine
  port                   = var.port
  instance_class         = "db.t2.micro"
  username               = var.master_username
  password               = var.master_password
  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.id
  skip_final_snapshot    = true
}