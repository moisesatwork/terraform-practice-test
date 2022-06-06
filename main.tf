variable "subnet_crn_1" {}
variable "subnet_crn_2" {}

data "ibm_resource_group" "rg" {
  is_default = true
}

resource "ibm_resource_instance" "test-pdns-cr-instance" {
  name              = "msz-test-pdns-cr-instance"
  resource_group_id = data.ibm_resource_group.rg.id
  location          = "global"
  service           = "dns-svcs"
  plan              = "standard-dns"
}

resource "ibm_dns_custom_resolver" "test" {
  name        = "msz-test-cr2"
  instance_id = ibm_resource_instance.test-pdns-cr-instance.guid
  description = "new test CR - TF"
  enabled     = true
  locations {
    subnet_crn = var.subnet_crn_1
    enabled    = true
  }
  locations {
    subnet_crn = var.subnet_crn_2
    enabled    = true
  }
}

resource "ibm_dns_zone" "pdns-1-zone" {
  name        = "moises-zone3.com"
  instance_id = ibm_resource_instance.test-pdns-cr-instance.guid
  description = "testdescription"
  label       = "testlabel"
}

resource "ibm_dns_secondary_zone" "test" {
  instance_id   = ibm_resource_instance.test-pdns-cr-instance.guid
  resolver_id   = ibm_dns_custom_resolver.test.custom_resolver_id
  description   = "first test"
  zone          = "moises-zone3.com"
  enabled       = true
  transfer_from = ["10.0.0.8"]
}
