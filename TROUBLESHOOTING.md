# 🔧 Deployment Troubleshooting Guide

## Common GitHub Actions Deployment Issues

### 1. **Job Status Check Failed**

**Issue**: The notification job shows "failure" instead of actual job status.

**Solution**: ✅ **Fixed** - Updated the workflow to properly check job results using `needs.deploy.result`.

### 2. **Docker Image Build Failures**

**Issue**: `collectstatic` fails with `STATIC_ROOT` not configured.

**Solution**: ✅ **Fixed** - Added proper static files configuration in Django settings.

### 3. **Missing GitHub Secrets**

**Error**: `Docker login failed` or `SSH connection failed`

**Check**: Verify these secrets are set in GitHub repository settings:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `EC2_HOST`
- `EC2_USERNAME`
- `EC2_PRIVATE_KEY`
- `EC2_PORT` (optional, defaults to 22)

### 4. **EC2 Connection Issues**

**Error**: `ssh: connect to host X.X.X.X port 22: Connection refused`

**Solutions**:
- ✅ Check EC2 security group allows SSH (port 22) from GitHub Actions IPs
- ✅ Verify EC2 instance is running
- ✅ Confirm SSH key is correct and added to EC2 `~/.ssh/authorized_keys`

### 5. **Docker Installation Issues**

**Error**: `Failed to install Docker` or `Docker service not starting`

**Solutions**:
- The script now includes better error handling
- Automatic Docker and Docker Compose installation
- Service start and enable commands

### 6. **Container Health Check Failures**

**Error**: `Container failed to start properly`

**Debug Steps**:
```bash
# SSH into EC2 and check logs
ssh ubuntu@your-ec2-ip
cd /opt/animal-classifier
sudo docker-compose -f docker-compose.prod.yml logs

# Check container status
sudo docker-compose -f docker-compose.prod.yml ps

# Check if Django is responding
curl http://localhost:8000
```

### 7. **Django Migration Issues**

**Error**: `Migration failed`

**Solutions**:
- Database permissions issue
- Missing database file or connection
- Check Django logs: `sudo docker logs container-name`

### 8. **Static Files Collection Issues**

**Error**: `Static files collection failed`

**Solution**: ✅ **Fixed** - Proper `STATIC_ROOT` configuration added.

## 🔍 Debug Commands

### Check GitHub Actions Logs
1. Go to your repository on GitHub
2. Click "Actions" tab
3. Click on the failed workflow run
4. Expand each step to see detailed logs

### Check EC2 Application Status
```bash
# SSH into EC2
ssh ubuntu@your-ec2-ip

# Check application status
cd /opt/animal-classifier
sudo docker-compose -f docker-compose.prod.yml ps

# View application logs
sudo docker-compose -f docker-compose.prod.yml logs -f

# Check if Django is accessible
curl -I http://localhost:8000

# Check system resources
htop
df -h
free -h
```

### Manual Deployment Test
```bash
# On EC2, test manual deployment
cd /opt/animal-classifier

# Pull latest image
sudo docker pull your-dockerhub-username/animal-classifier:latest

# Restart services
sudo docker-compose -f docker-compose.prod.yml up -d

# Check status
sudo docker-compose -f docker-compose.prod.yml ps
```

## 🚨 Emergency Recovery

### If Deployment Completely Fails
```bash
# SSH into EC2
ssh ubuntu@your-ec2-ip

# Stop all containers
cd /opt/animal-classifier
sudo docker-compose -f docker-compose.prod.yml down

# Clean up everything
sudo docker system prune -af

# Re-run deployment script manually
curl -fsSL https://raw.githubusercontent.com/your-username/your-repo/main/deploy-script.sh -o deploy.sh
chmod +x deploy.sh
./deploy.sh
```

### Reset EC2 Instance
```bash
# Complete reset (nuclear option)
sudo rm -rf /opt/animal-classifier
sudo docker system prune -af --volumes
sudo systemctl restart docker

# Then re-run GitHub Actions deployment
```

## 📧 Getting Help

If you're still experiencing issues:

1. **Check GitHub Actions logs** for specific error messages
2. **SSH into EC2** and run the debug commands above
3. **Check security groups** and network connectivity
4. **Verify all secrets** are correctly set in GitHub
5. **Test Docker image locally** if possible

## 🎯 Most Common Solutions

1. **Re-run the GitHub Action** - Sometimes it's just a temporary network issue
2. **Check EC2 instance status** - Make sure it's running and accessible
3. **Verify secrets** - Double-check all GitHub secrets are set correctly
4. **Check security groups** - Ensure ports 22 and 80 are open
5. **Monitor resource usage** - EC2 might be out of memory/disk space

---

**Note**: The workflow now includes comprehensive error handling and detailed logging to help identify issues faster!
