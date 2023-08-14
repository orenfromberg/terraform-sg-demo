# terraform-sg-demo

1. set the `vpc_id` and `common_tags` in `vars.tfvars`:

```
vpc_id = "vpc-xxxxxxxx"
common_tags = {
  Application = "terraform-sg-demo"
  ClusterName = "my-cluster"
}
```

2. initialize the terraform backend:
```
tf init
```

3. apply the terraform

```
tf apply -var-file=vars.tfvars
```

4. change the module to the new one and run tf init again
5. try to apply terraform (it will fail)
6. do a terraform plan
```
tf plan -var-file=vars.tfvars -out=out.tfplan
tf show -json out.tfplan > tfplan.json
```

7. Run `generate_tf_script.sh`
8. Run `migrate.sh`
9. Run terraform apply again
10. Run terraform plan again to see `No changes.`
11. Run `tf destroy -var-file=vars.tfvars` to clean up

