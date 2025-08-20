# 🚀 EC2 Deployment with GitHub Actions

This guide will help you set up automated deployment of your Django ML Animal Classification app to AWS EC2 using GitHub Actions.

## 📋 Prerequisites

### 1. AWS EC2 Instance
- Ubuntu 20.04 LTS or newer
- At least 2GB RAM (4GB recommended for ML models)
- Security group allowing HTTP (port 80) and SSH (port 22)
- Elastic IP address (recommended for production)

### 2. Docker Hub Account
- Create account at [hub.docker.com](https://hub.docker.com)
- Create a repository named `animal-classifier`

### 3. GitHub Repository
- Your code pushed to GitHub
- Access to repository settings for secrets

## 🔐 Required GitHub Secrets

Add these secrets in your GitHub repository settings (`Settings > Secrets and variables > Actions`):

### Docker Hub Secrets
```
DOCKERHUB_USERNAME: your-dockerhub-username
DOCKERHUB_TOKEN: your-dockerhub-access-token
```

### EC2 Secrets
```
EC2_HOST: your-ec2-public-ip-or-domain
EC2_USERNAME: ubuntu
EC2_PRIVATE_KEY: your-ec2-private-key-content
EC2_PORT: 22
```

## 🔑 Setting Up SSH Key for EC2

### 1. Generate SSH Key Pair (if you don't have one)
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

### 2. Add Public Key to EC2
```bash
# Copy your public key
cat ~/.ssh/id_rsa.pub

# SSH into your EC2 instance
ssh ubuntu@your-ec2-ip

# Add the public key to authorized_keys
echo "your-public-key-content" >> ~/.ssh/authorized_keys
```

### 3. Add Private Key to GitHub Secrets
```bash
# Copy your private key content (entire file)
cat ~/.ssh/id_rsa
```
Paste this content into the `EC2_PRIVATE_KEY` secret in GitHub.

## 🐳 Docker Hub Setup

### 1. Create Access Token
1. Go to [Docker Hub Security Settings](https://hub.docker.com/settings/security)
2. Click "New Access Token"
3. Name it "github-actions"
4. Copy the token and add it to `DOCKERHUB_TOKEN` secret

### 2. Create Repository
1. Go to [Docker Hub Repositories](https://hub.docker.com/repositories)
2. Click "Create Repository"
3. Name it `animal-classifier`
4. Set visibility (public/private)

## ⚙️ EC2 Initial Setup

### 1. Connect to EC2
```bash
ssh ubuntu@your-ec2-ip
```

### 2. Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 3. Install Required Packages
```bash
# Install curl and wget
sudo apt install -y curl wget

# Install Docker (optional - will be installed by deployment script)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
```

### 4. Configure Security Group
Ensure your EC2 security group allows:
- SSH (port 22) from your IP
- HTTP (port 80) from anywhere (0.0.0.0/0)
- HTTPS (port 443) from anywhere (optional)

## 🔄 Deployment Process

### Automatic Deployment
The GitHub Actions workflow will automatically:

1. **Test**: Run Django tests
2. **Build**: Create Docker image and push to Docker Hub
3. **Deploy**: SSH to EC2 and deploy the application

### Manual Deployment
You can also run the deployment script manually on EC2:

```bash
# Download the script
wget https://raw.githubusercontent.com/your-username/your-repo/main/deploy-script.sh

# Make it executable
chmod +x deploy-script.sh

# Set environment variables
export DOCKERHUB_USERNAME="your-username"
export DOCKERHUB_TOKEN="your-token"

# Run deployment
./deploy-script.sh
```

## 🌐 Domain Configuration (Optional)

### 1. Point Domain to EC2
- Update your domain's A record to point to your EC2's Elastic IP

### 2. Update Environment Variables
```bash
# On EC2, edit the environment file
sudo nano /opt/animal-classifier/.env

# Update ALLOWED_HOSTS
ALLOWED_HOSTS=your-domain.com,www.your-domain.com
```

### 3. SSL Certificate (Optional)
```bash
# Install Certbot
sudo apt install -y certbot

# Get SSL certificate
sudo certbot certonly --standalone -d your-domain.com
```

## 📊 Monitoring and Logs

### View Application Logs
```bash
# On EC2
cd /opt/animal-classifier
sudo docker-compose -f docker-compose.prod.yml logs -f web
```

### Check Container Status
```bash
sudo docker-compose -f docker-compose.prod.yml ps
```

### Monitor System Resources
```bash
# Install htop
sudo apt install htop
htop

# Check Docker stats
sudo docker stats
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Deployment Fails
```bash
# Check GitHub Actions logs
# Go to your repository > Actions > failed workflow > view logs

# Check EC2 connectivity
ssh ubuntu@your-ec2-ip
```

#### 2. Application Not Accessible
```bash
# Check if containers are running
sudo docker ps

# Check application logs
sudo docker logs container-name

# Check security group settings
# Ensure port 80 is open
```

#### 3. Docker Issues
```bash
# Restart Docker service
sudo systemctl restart docker

# Clean up Docker system
sudo docker system prune -af
```

### Useful Commands

```bash
# Restart application
cd /opt/animal-classifier
sudo docker-compose -f docker-compose.prod.yml restart

# Update application
sudo docker-compose -f docker-compose.prod.yml pull
sudo docker-compose -f docker-compose.prod.yml up -d

# View environment variables
sudo docker-compose -f docker-compose.prod.yml exec web env
```

## 🔐 Security Best Practices

1. **Use strong secrets**: Generate secure keys and tokens
2. **Limit SSH access**: Use specific IP ranges in security groups
3. **Regular updates**: Keep EC2 and Docker updated
4. **Monitor logs**: Set up log monitoring and alerts
5. **Backup data**: Regular backups of database and media files

## 📈 Scaling Considerations

For production deployments, consider:

1. **Load Balancer**: Use Application Load Balancer for multiple instances
2. **Database**: Use RDS instead of SQLite
3. **Storage**: Use S3 for static/media files
4. **Monitoring**: Use CloudWatch or similar monitoring solutions
5. **Auto Scaling**: Set up auto-scaling groups

## 🆘 Support

If you encounter issues:

1. Check GitHub Actions logs
2. Review EC2 system logs: `sudo journalctl -u docker`
3. Check application logs: `sudo docker logs container-name`
4. Verify all secrets are correctly set in GitHub

---

## 📝 Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `DEBUG` | Django debug mode | `0` (production) |
| `SECRET_KEY` | Django secret key | `your-secret-key` |
| `ALLOWED_HOSTS` | Allowed hostnames | `your-domain.com,*` |
| `DOCKERHUB_USERNAME` | Docker Hub username | `your-username` |

Happy deploying! 🎉
