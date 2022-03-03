# Secure DKG node setup

❗**Current development should be considered a work in progress.**

## Setting up a DKG Node

This repo includes code to run a DKG Node on AWS using [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/). To get started, ensure you have both Terraform and Ansible installed locally.

In addition, [create an AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) and an [IAM role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create.html) that has the appropriate permissions for the contained infrastructure setup. Ensure the AWS credentials are exported to the appropriate computer running the setup. When setup, you should have the following files in `~/.aws` :
- `config`
- `credentials`

Ensure that you chose the right AWS region.

### Building AWS Infra

From the root directory, you should first set-up an AWS account and [create a bucket](https://docs.aws.amazon.com/quickstarts/latest/s3backup/step-1-create-bucket.html) to store your terraform state. You must remember to do the following steps:
- Click create bucket. 
- Name the bucket something you will remember
- Then ensure you choose the correct region
- Then just the bucket with all the default settings.

Then [create a dynamodb table](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-1.html) to manage state locks. This requires that you do:
- Go to dynamodb and click create table
- Name the bucket something you will remember
- Name the primary key `LockID` and keep as string
- Keep default settings checked off and click create

**Then run:**

```sh
terraform init -upgrade \
  -backend-config="bucket=YOUR-BUCKET-NAME" \
  -backend-config="dynamodb_table=YOUR-TABLE-NAME" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=us-east-1"
```

Note: if you have an error, you may need to [review your AWS credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication) for Terraform.


Also, you will need to create a public & private key pair to access your instance.
We assume that's defined in `~/.ssh/dkg-node.pub`. It can be created with:

```
ssh-keygen -P "" -m PEM -f SSH-KEY-PAIR-NAME
```

Then add this key to your ssh agent:

```
ssh-add ~/.ssh/<SSH_PRIV_KEY>
```

You will also have to add this ssh key to your approved github ssh keys, since ansible tries to pull
the dkg repository through ssh. 

Next, plan the terraform changes:

```sh
terraform plan \
  -var admin_public_key="$(cat ~/.ssh/dkg-node.pub)"
```

Then, if that looks good, apply the terraform changes:

```sh
terraform apply \
  -var admin_public_key="$(cat ~/.ssh/dkg-node.pub)"
```

The resulting **outputs** should read out the following:

```
authority_node_ip_address = "<PRIVATE_IP_ADDR>"
bastion_ip_address = "<PUBLIC_IP_ADDR>"
full_node_ip_address = [
  "<PRIVATE_IP_ADDR>",
]
full_node_secondary_ip_address = [
  "<PRIVATE_IP_ADDR>",
]
```

Once you have everything up, you'll need to construct your Ansible inventory and ssh_config. This can be done by running:

```
terraform output -json >> output.json
```

The above command will create a file `output.json` that outlines the terraform instances.

Next we will use the `output.json` file we created above to generate our Ansible `host` file and `ssh_config` by running the following command:

```
cat output.json | python3 ./ansible/generate_inv.py
```

**Note:** you'll need python3 installed. You may need to run this command differently in Powershell.

**Note:** after you change any nodes created by terraform, you will need to re-run this command.

To make sure the command was successfully executed please `ls` the current directory. You should see a `host` and `ssh_config` file present.

You will then have to update your hosts file manually so it has the `ansible_ssh_private_key_file` variable added in, like so:

```
[authority_node]
<PRIV_IP_ADDR>

[bastion]
<PUB_IP_ADDR> ansible_ssh_private_key_file=~/.ssh/<SSH_PRIV_KEY>

[full_node]
<PRIV_IP_ADDR> ansible_ssh_private_key_file=~/.ssh/<SSH_PRIV_KEY>
<PRIV_IP_ADDR> ansible_ssh_private_key_file=~/.ssh/<SSH_PRIV_KEY>
```

> TODO - make this automatic, so we don't have to worry about the above variables added to be overwriten when running the generate_inv.py script

#### Setting up DKG application

Setting up each node is a matter of simply running the Ansible playbooks. Make sure your inventory is up-to-date by running the generate_inv.py command above!

To run the playbook and configure the servers, run:
```
ansible-playbook -i hosts --ssh-extra-args "-F ./ssh_config" ansible/playbooks/chain.yml
```
> Note - this will take about 30 or more minutes to compile, specifically the compiling of the dkg-node is what takes super long.
> You can expect around 200 retries. 

# Restarting the whole infrastructure

You may run into a scenario where you want to start from a clean slate. See steps below:

## Get a clean slate locally
- Run `terraform destroy -var admin_public_key="$(cat ~/.ssh/<YOUR_SSH_PUB_KEY)"`
- Manually delete the `.terraform` folder and the `.terraform.lock.hcl` and `output.json` files
- Delete the `hosts` and `ssh_config` file

## Clean up AWS
- Delete the terraform s3 state, which is named `terraform.tfstate` in the s3 console. You select
  the file with the checkbox, and then click delete.
- Go into dynamodb --> tables --> click the items tab --> click the check mark --> click actions and delete


## Make sure your ssh is configured
- You might have to run `ssh-add ~/.ssh/<YOUR_PRIV_SSH_KEY>` to add it back to your ssh agent. You
  can always double check with `ssh-add -L`
- If you change the ssh key you use, you will have to configure the new one, the same way you did
  before. And you will have to make sure you rename the commands to match this new ssh key file



After doing all of that, you can start again from the top of the README with `terraform init`.