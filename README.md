OpenStack-in-Openstack
======================

You can execute this script by running:

```bash
terraform init
terraform plan -var 'secgroup=<secgroup_id>' -var 'external_gateway=<gateway_net_id>' -var 'keypair=<keypair_id>'
```

## Disclaimer:

It might not work at the moment!