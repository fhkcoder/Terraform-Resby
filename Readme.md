### Create OIDC Provider for Github

## OIDC provider
```sh
aws iam create-open-id-connect-provider \
--cli-input-json file://oidc-provider.json
```

## OIDC provider role
```sh
aws iam create-role \
--role-name OIDC-Role_Faisal  \
--assume-role-policy-document file://oidc-role-trust-policy.json
```

## OIDC role permision policy
```sh
aws iam create-policy \
--policy-name OIDC-permission-policy \
--policy-document file://permission-policy.json
```

```sh
aws iam attach-role-policy \
--role-name OIDC-Role_Faisal \
--policy-arn arn:aws:iam::872515279375:policy/OIDC-permission-policy
```

## Create an S3 bucket for backend with versioning enabled
```sh
aws s3api create-bucket \
--bucket resby-faisal-bucket0001 \
--region us-east-1
```
```sh
aws s3api put-bucket-versioning \
--bucket resby-faisal-bucket0001 \
--versioning-configuration Status=Enabled
```

## Remove Public Access Block to implement bucket policy
```sh
aws s3api delete-public-access-block --bucket resby-faisal-bucket0001
```

## Restricting anyone else apart from the OIDC Role to access the bucket
```sh
aws s3api put-bucket-policy \
--bucket resby-faisal-bucket0001 \
--policy file://bucket-policy.json \
--region us-east-1
```