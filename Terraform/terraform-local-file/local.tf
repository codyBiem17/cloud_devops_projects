resource "local_file" "pet" {
  filename = "Terraform/pets.txt"
  content = "We love pets!"
  file_permission = "0700"
}
