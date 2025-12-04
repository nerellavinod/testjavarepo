resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = true
}
