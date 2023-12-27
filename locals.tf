locals {
  common_tags = {
    company    = "Bluejay.internal"
    owner      = "Gabinator"
    team-email = "devops-team@bluejay.com"  #"team-devops@jjtech.com"
    time       = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
  }

}