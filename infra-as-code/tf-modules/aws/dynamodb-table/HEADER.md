# Create DynamoDB Tables with Versatile Configurations


We have drawn inspiration from the dedicated efforts of a team at this link: [https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest](https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest)

Our implementation is centered around utilizing this module to establish DynamoDB Tables. At present, our support encompasses several types of DynamoDB Tables, namely:

- Basic Table
- Global Table with Replicas spanning multiple regions
- Autoscaling-enabled Table

The flexibility of customization is always available to suit specific requirements. Below is a sample code exemplifying its application.

For more examples refer [here](https://github.tmc-stargate.com/devex-src/skywalker-sync/tree/main/samples/dynamodb)

```hcl
module "dynamodb_table_basic_example" {

  ## Source to pull module `aws_dynamodb-table` from JFrog Artifactory
  source = "artifactory.stargate.toyota/devex-terra__devex/aws_dynamodb-table/stargate"
  version = "1.0.0"

  ## Source to pull module from `github` repository
  // source = "git@github.com:devex-src/skywalker-sync.git//tf-modules/aws/dynamodb-table?ref=main"

  name     = "basic-table-example"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "N"
    }
  ]

  required_tags = local.required_tags
}


output "dynamodb_table_basic_example_id" {
  value = module.dynamodb_table_basic_example.dynamodb_table_id
}
output "dynamodb_table_basic_example_arn" {
  value = module.dynamodb_table_basic_example.dynamodb_table_arn
}


```



<!-- BEGIN_TF_DOCS -->


<!-- END_TF_DOCS -->