output "endpoint" {
  value = aws_docdb_cluster.docdb.endpoint
}

output "port" {
  value = aws_docdb_cluster.docdb.port
}

output "master_username" {
  value = aws_docdb_cluster.docdb.master_username
}

output "master_password" {
  value = aws_docdb_cluster.docdb.master_password
}
