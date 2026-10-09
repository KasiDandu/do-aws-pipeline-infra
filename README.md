# do-aws-pipeline-infra

Infrastructure layer. CD-only repo: no Python, only Terraform roots and YAML config.

```
{env}/{data-pipeline}/{blueprint-type}/
├── main.tf                 # platform team: calls a versioned blueprint module
├── glue_job_config.yaml    # written by do-gh-shared-actions (glue-build-publish-deploy)
└── config.yaml             # written by do-gh-shared-actions (lambda-build-publish-deploy)
```

- `02-apply-single-env.yaml` runs on every push that touches an env folder: it finds the
  changed `{env}/{pipeline}/{blueprint}` paths and runs `terraform init`, `plan`, `apply` for
  each. Run it by hand for `plan`, `apply` or `destroy` on one path.
- `unlock-state.yaml` force-unlocks a stuck state lock through the shared workflow.

Data engineers never write Terraform here.

## Setup

1. Replace `ACCOUNT_ID` in each `*/ppi-triage/process/main.tf` backend block.
2. Add repo variables `AWS_ROLE_ARN` and `AWS_REGION` (or let the platform repo set them
   through `common_variables`).
