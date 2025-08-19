# Firebase Hosting Deployment

## Deploying Your SuperApp Documentation

This guide walks you through deploying your Docusaurus documentation site to Firebase Hosting, providing a professional platform to showcase your revolutionary architecture.

## Prerequisites

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name your project (e.g., "flutter-superapp-docs")
4. Enable Google Analytics (optional)
5. Create project

## Firebase Setup

### 1. Initialize Firebase in Your Project

```bash
cd docs-site
firebase login
firebase init
```

### 2. Firebase Configuration Choices

When prompted, select:
- ✅ **Hosting: Configure files for Firebase Hosting**
- Select your Firebase project
- **Public directory**: `build`
- **Single-page app**: `Yes`
- **Automatic builds with GitHub**: `Yes` (optional)

### 3. Configure firebase.json

```json
{
  "hosting": {
    "public": "build",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

## Deployment Process

### 1. Build the Documentation

```bash
npm run build
```

This creates an optimized production build in the `build` directory.

### 2. Preview Locally (Optional)

```bash
firebase serve
```

Visit `http://localhost:5000` to preview your site.

### 3. Deploy to Firebase

```bash
firebase deploy
```

Your site will be available at: `https://your-project-id.web.app`

## Automated CI/CD Pipeline

### GitHub Actions Deployment

Create `.github/workflows/deploy-docs.yml`:

```yaml
name: Deploy Documentation

on:
  push:
    branches: [ main ]
    paths: [ 'docs-site/**' ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: docs-site/package-lock.json
        
    - name: Install dependencies
      run: |
        cd docs-site
        npm ci
        
    - name: Build documentation
      run: |
        cd docs-site
        npm run build
        
    - name: Deploy to Firebase
      uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        projectId: your-project-id
        channelId: live
        entryPoint: ./docs-site
```

### Setup Firebase Service Account

1. Go to Firebase Console → Project Settings → Service Accounts
2. Generate new private key
3. Add the JSON content as `FIREBASE_SERVICE_ACCOUNT` secret in GitHub

## Custom Domain Setup

### 1. Add Custom Domain in Firebase

1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Enter your domain (e.g., `docs.yourcompany.com`)
4. Follow verification steps

### 2. DNS Configuration

Add these DNS records to your domain provider:

```
Type: A
Name: docs
Value: 151.101.1.195

Type: A  
Name: docs
Value: 151.101.65.195
```

## Performance Optimization

### 1. Enable Compression

Firebase automatically enables gzip compression for text files.

### 2. CDN Configuration

Firebase Hosting includes global CDN by default for optimal performance.

### 3. Caching Strategy

Configure caching headers in `firebase.json`:

```json
{
  "hosting": {
    "headers": [
      {
        "source": "/service-worker.js",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache"
          }
        ]
      },
      {
        "source": "**/*.@(html|json)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=300"
          }
        ]
      }
    ]
  }
}
```

## Analytics and Monitoring

### 1. Google Analytics Integration

Add to `docusaurus.config.ts`:

```typescript
const config: Config = {
  // ... other config
  themeConfig: {
    gtag: {
      trackingID: 'G-XXXXXXXXXX',
      anonymizeIP: true,
    },
  },
};
```

### 2. Firebase Performance Monitoring

```html
<!-- Add to static/index.html -->
<script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-performance.js"></script>
<script>
  firebase.performance();
</script>
```

## Security Configuration

### 1. Content Security Policy

Add CSP headers:

```json
{
  "hosting": {
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Content-Security-Policy",
            "value": "default-src 'self'; script-src 'self' 'unsafe-inline' https://www.googletagmanager.com; style-src 'self' 'unsafe-inline'"
          }
        ]
      }
    ]
  }
}
```

### 2. HTTPS Enforcement

Firebase automatically enforces HTTPS for all custom domains.

## Deployment Scripts

### Package.json Scripts

Add these to your `package.json`:

```json
{
  "scripts": {
    "build": "docusaurus build",
    "deploy": "npm run build && firebase deploy",
    "deploy:preview": "npm run build && firebase hosting:channel:deploy preview",
    "serve": "firebase serve"
  }
}
```

### Quick Deployment Script

Create `deploy.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 Deploying Flutter SuperApp Documentation..."

# Build the site
echo "📦 Building documentation..."
npm run build

# Deploy to Firebase
echo "🔥 Deploying to Firebase..."
firebase deploy

echo "✅ Deployment complete!"
echo "🌐 Site available at: https://your-project-id.web.app"
```

Make it executable:
```bash
chmod +x deploy.sh
```

## Environment-Specific Deployments

### Development Environment

```bash
# Deploy to preview channel
firebase hosting:channel:deploy dev --expires 7d
```

### Staging Environment

```bash
# Deploy to staging channel
firebase hosting:channel:deploy staging --expires 30d
```

### Production Environment

```bash
# Deploy to live channel
firebase deploy --only hosting
```

## Monitoring and Maintenance

### 1. Check Deployment Status

```bash
firebase hosting:channel:list
```

### 2. View Hosting Metrics

Access Firebase Console → Hosting → Usage tab for:
- Bandwidth usage
- Storage usage
- Request counts
- Geographic distribution

### 3. Update Dependencies

Regular maintenance schedule:

```bash
# Monthly dependency updates
npm update
npm audit fix

# Rebuild and redeploy
npm run deploy
```

## Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   # Clear cache and rebuild
   npm run clear
   npm run build
   ```

2. **Deployment Timeout**
   ```bash
   # Increase timeout
   firebase deploy --timeout 2000s
   ```

3. **Custom Domain Issues**
   - Verify DNS propagation: `dig docs.yourcompany.com`
   - Check SSL certificate status in Firebase Console

### Debug Commands

```bash
# Check Firebase CLI version
firebase --version

# Debug deployment
firebase deploy --debug

# View deployment logs
firebase hosting:channel:list
```

## Success Metrics

After deployment, your documentation will provide:

- ⚡ **Fast Loading**: Global CDN ensures sub-2-second load times
- 🔒 **Secure**: HTTPS by default with modern security headers
- 📊 **Analytics**: Detailed visitor insights and usage patterns
- 🌍 **Global Reach**: Available worldwide with optimal performance
- 🚀 **Professional Presence**: Enterprise-grade hosting platform

## Next Steps

Your Flutter SuperApp Architecture documentation is now live and accessible to developers worldwide! 🎉

For more information, explore:
- [Architecture Overview](../architecture/overview.md)
- [Module Development](../modules/creating-modules.md)
- [Framework Comparisons](../comparisons/framework-comparison.md)
