# 🌐 AWS Load Balancer Showcase with Terraform

This project demonstrates how to build a **highly available** infrastructure using **Terraform**, **AWS**, and an **Application Load Balancer (ALB)**.

It provisions:
- A custom VPC with public subnets in 2 availability zones
- Two EC2 instances running Nginx
- An Internet Gateway and Route Tables
- An Application Load Balancer (ALB) with listener rules and health checks
- Output of the Load Balancer DNS for quick testing

---

## 🚀 Purpose

This was built as a **learning project** to understand what's *really* required behind the scenes for a load balancer to function properly in AWS. While the concept of a load balancer is simple, the infrastructure surrounding it (routing, security, networking) is anything but!

---

## 📚 What I Learned

1. **Custom VPCs over Default VPCs**  
   I chose to create a custom VPC to fully control IP ranges, subnets, and routing — crucial for real-world infrastructure.

2. **Public Subnets Need Route Table Config**  
   Even though subnets are public (`map_public_ip_on_launch = true`), they must be explicitly associated with a route table that routes to an Internet Gateway.

3. **Listener Rules & Target Groups**  
   The load balancer uses listener rules to forward traffic to a target group. The group registers healthy EC2 instances dynamically, using health checks.

4. **Security Groups Are Key**  
   Without a properly defined security group allowing inbound traffic on port 80, the load balancer will time out or return 502 errors.

5. **Automation With Terraform Makes It Reproducible**  
   The entire setup is described as code and can be torn down or recreated with one command.

---

## 🛠️ Stack

- **Terraform v1.6+**
- **AWS Application Load Balancer (ALB)**
- **EC2 + Nginx**
- **Amazon Linux 2 AMIs**
- **PyCharm** (IDE)

---

## 🧪 Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- AWS credentials configured (via `aws configure` or environment variables)

### Clone and Deploy

```bash
git clone https://github.com/janphilippgutt/loadbalancer_showcase
cd loadbalancer_showcase
terraform init
terraform apply
```

## 🌐 Output

After deployment, Terraform will show the public DNS name of the Load Balancer.

Open it in a browser — you'll see either:

    Web Server 1 – AZ1

    Web Server 2 – AZ2

...depending on how the load balancer routes your request.
## 🧹 Cleanup

To avoid charges, always destroy resources when done:

```bash
terraform destroy
```

## 🧠 Final Thoughts

While this project builds a "simple" load balancer, it shows how much infrastructure is required for even basic web traffic routing in the cloud. This was a hands-on way to reinforce core AWS networking concepts — and a practical Terraform learning experience.