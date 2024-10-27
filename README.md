# Terraform AWS ECS Fargate Module

The module is developed to quickly implement fargate cluster for microservices with ecs connect. Following are the features

## Features
- Secret Manager
- Parameter Store
- Elastic container registry (ECR)
- Auto Scaling
- Cloudwatch Dashboard
- SSL cert on LB
- Cloudwatch Dashboard


## Security Recommendations
We suggest that you provide KMS keys for ECR and Cloudwatch encryption.

## Example
Following example creates fargate cluster for service
```
module "test" {
  source            = "./../"
  region            = "us-east-1"
  app_name          = "app"
  app_port          = "80"
  env               = "dev"
  vpc               = module.vpc
  app_image         = "nginx:1.13.9-alpine"
  service_connect_enabled = true
  cloudmap_namespace_arn = aws_service_discovery_service.app.arn
}
```
More examples: [Examples](./examples/)

## Input Variables
|   Variable  	              |    Required		  | 	 Default	| 	   Type	 	|	   Info	 	|    Example    |
| -------------               | ------------- 	| ------------- | ------------- | ------------- | ------------- |
| vpc 		              	    | 	    Y 		    | 	    -	 	     |	  object 	  | 	    -	 	|	module.vpc from terraform vpc module will be one example |
| region 	              	    | 	    Y 	     	| 	    -	        	|	  string 	| 	    -	 	|	"us-east-1" |
| env 		              	    | 	    Y 		    | 	    -	 	|	  string 	| 	    -	 	|	"dev" |
| app_name 	                  | 	    Y 		     | 	    -	 	|	  string 	| 	    -	 	|	"test" |
| app_port 	              	  | 	    Y 		| 	    -	 	|	  string 	| 	    -	 	|	"80" |
| cloudmap_service            | 	   	Y 		| 	    -	 	|	  object 	| 	    -	 	|	aws_service_discovery_private_dns_namespace.main |
| fargate_cpu                 | 	   	N 		| 	  "1024"	|	  string 	| 	    -	 	|	"2048" |              
| fargate_memory              | 	   	N 		| 	  "2048"	|	  string 	| 	    -	 	|	"4096" |              
| prefix 		                  | 	    N 		| 	  "EFA"	 	|	  string 	| 	    -	 	|	"AGT" |
| app_image 	                | 	    N 		| 	  "none"	|	  string 	| Default will create ECR	 	|	"nginx:1.13.9-alpine" |
| engress_cidr_blocks         |       N     |    vpc.default.cidr_block     | list(string) | egress cidr blocks allowed for app mesh services | ["1.2.3.4/0"] |
| container_insights          |       N     |   true    | bool       | enable container insights for ecs clusters |  false |
| sg_prefixs                 |       N     |       []    |  list(string) | vpc endpoint prefixs to be added to sg    | ["com.amazonaws.us-east-1.s3"] |
| min_app_count               | 	   	N 		| 	    1	 	|	  number 	| 	    -	 	|	1 |
| max_app_count               |       N     |      10   |   number  |       -   | 100 |
| log_retention_in_days       |       N     |      90   |   number  |       log retention in days   | 14 |
| ecr_kms_key_arn             |       N     |      ""   |   string  | KMS keys used to encrypt ECR images | aws_kms_key.ecr_kms.key_id |
| cloudwatch_kms_key_arn      |       N     |      ""   |   string  | KMS keys used to encrypt cloudwatch logs | aws_kms_key.cloudwatch_log_kms.arn | 
| extra_ports 	              | 	   	N 		| 	    []	 	|  list(string)	| Open extra port in task definition	 	|	["443","542"] |
| enable_cross_zone_load_balancing  |       N     |       false    |  bool | Enable cross zone load balancing for lb    | true |
| lb_access_logs_s3_bucket    |       N     |       ""    |  string | lb_access_log must be enable to provide s3 bucket name to store lb access logs    | lb-access-log-bucket |
| secrets 	              	  | 	   	N 		| 	    []	 	|  list(object) | Will add IAM permissions and secrets to task definition |	[aws_secretsmanager_secret.main.usernamer,aws_secretsmanager_secret.main.password]|
| parameters                  |       N     |       []    | list(object)  | Will add IAM permissions and parameters to task defintion as env variables | [aws_ssm_parameter.main.configs] |
| policy_arn_attachments      |     N       |       []    | list(string)   | can provide addition policies arns to be attached to ecs roles | [arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole] |
| certificate                 | 	   	N 		| 	  false 	|	  bool 	| make sure to set this to true if providing certificate arn |	true |
| certificate_arn             |       N     |     "none"  |   string  |set certificate on LB| aws_acm_certificate.privateCA.arn |
| service_connect_enabled              | 	   	N 		| 	   false	|	  bool 		|to enable service connect|	true |
| cloudmap_namespace_arn              |      Y     |      "none"  |   string    |Arn of registered cloudmap namespace| true |
| sc_ingress_port_override              |      N     |      "null"  |   string    |port number for proxy to listen on if not default, which is container port in case of ecs fargate| true |
| target_group_arn              |      Y     |      ""  |   string    |load balancer target group arn| true |
| lb_listener_rule              |      Y     |      ""  |   object    |load balancer listener| true |
| xray			              | 	   	N 		| 	   false	|	  bool 		|add xray daemon as sidecar	 	|	true |
| tags               		  | 	   	N 		|{Terraform = "true",Module    = "ECS-Fargate-ServiceConnect"}	 |	  map(string) 	| 	    -	 	|	{name = "test"} |

## Output Variables
|   Variable  	   | 
| -------------    |
| ecs_cluster_arn  | 
| ecs_service_arn  |
| ecr_repo_url 	   |
| ecr_repo_name    |


## License

This project is licensed under the GNU General Public License v3.0 License - see the [LICENSE.md](LICENSE.md) file for details