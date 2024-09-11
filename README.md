# AWSS3-bucket
First go at using Terraform with AWS. Did it as interview practice



Objective:

-There should be an S3 bucket referenced in Terraform as bucket and named upload-bucket. The ACL should be private.

-There should be an SQS queue referenced in Terraform as queue and named upload-queue.

-The above queue should have:
  -A delay specified as 60 seconds,
  -A max message size of 8kB,
  -Discard messages after 48 hours,
  -Wait for up to 15 seconds for messages to be received.
  -There should be an IAM policy document created as Terraform data, referenced as iam_notif_policy_doc, which should describe the policy that will be used by the bucket notification hook     to post messages to the queue. Alternatively, you can use an EOF expression in the policy and omit this step.

-The above document should contain one statement with an ID equal to 1.

-The above statement should:
  Work only for upload-bucket and be tested by checking if the source ARN matches,
  Work only on upload-queue and allow messages to be sent to it,
  Use the AWS type of principal with identifiers set to *.

  
-The above document should be used to create the upload-queue policy referenced in Terraform as notif_policy. You may use an inline policy implementing the same thing instead of using a policy document.

-Finally, bucket notification should be enabled (referenced in Terraform as bucket_notif) to send a message to upload-queue when an object is created in upload-bucket.

-All references to other resources should be specified as Terraform identifiers, not as text.
