## 1. Root Access

- The [root_account_used.yml](./rules/root_account_used.yml) can be used to find if root access has been used or not.
- I was not logged in as the root user, but I could do some actions in the IAM.
- Go to IAM -> Root access management -> Delete SQS queue policy.
- Create a dummy queue and give its arn.
- I was able to observe actions performed as root.
- And the rule was able to detect it in splunk.

## 2. Console login without MFA

- I don't haven't activated MFA. So whenever I logged in, it created a entry and can be queried using the [aws_cloudtrail_console_login_success_without_mfa.yml](./rules/aws_cloudtrail_console_login_success_without_mfa.yml) file.

## 3. Someone tampering with logging

- Went to cloudtrail and stopped logging to generate that event and turned on logging back on.
- This generated the log. Used the query from [aws_cloudtrail_disable_logging.yml](./rules/aws_cloudtrail_disable_logging.yml) to search in splunk and saw the event.

## 4. Security group modified

- To trigger this event, I created a security-group and create a inbound rule to accept TCP traffic from from the internet on any port.
- It created a `AuthorizeSecurityGroupIngress` event and logged it in the cloudtrail.
- Using [aws_cloudtrail_security_group_change_ingress_egress.yml](./rules/aws_cloudtrail_security_group_change_ingress_egress.yml) to create the query for splunk.
- Used it to search the log and was able to find the event in splunk.

## 5. AWS IAM Role Policy modification or creation

- To trigger this event go to IAM, create a role, attach a policy and create the role.
- Then edit the role and detach the policy.
- The query from the [aws_iam_role_policy_modification.yml](./rules/aws_iam_role_policy_modification.yml) file was able to detect the events.
- To view those events in cloudtrail, I had to change region.

## 6. IAM access key creation

- Go to IAM -> IAM User. Create a user and go to security credential and create a security key.
- This will trigger the `CreateAccessKey` event and can be visible in the cloudtrail.
- This can be queried in splunk by using [aws_iam_access_key_creation.yml](./rules/aws_iam_access_key_creation.yml) file to create the query to use in splunk.

## 7. AWS infrastructure discovery

- Since I used terraform to create the resource, I already has logs( which are false +ve) to query and find out.
- In other case we can also run the below commands to create events.
	```bash
	aws ec2 describe-instances --region ap-southeast-2
	aws ec2 describe-vpcs --region ap-southeast-2
	aws ec2 describe-security-groups --region ap-southeast-2
	```
- Then use the [aws_cloud_infrastructure_discovery.yml](./rules/aws_cloud_infrastructure_discovery.yml) to create a query for splunk.