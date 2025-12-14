# Lambda-Optimized Application Folder

## Why a Separate `terraform/app/` Folder?

This folder contains a **Lambda-specific version** of the application, separate from the root `/app/` folder used for local development. Here's why we need both:

---

## Key Differences

### 1. **Lambda Handler Requirement**

AWS Lambda requires a specific **handler function** to process events:

```python
# Lambda handler (terraform/app/app.py)
def lambda_handler(event, context):
    return serverless_wsgi.handle_request(app, event, context)
```

- **Lambda** expects `lambda_handler(event, context)` as the entry point
- **Local Flask** runs with `app.run()` directly
- The handler bridges API Gateway events to Flask using `serverless-wsgi`

### 2. **Different Dockerfile Configurations**

> **⚠️ Serverless Trade-off**: This separate folder is **extra effort specific to Lambda**. If you opted for **ECS (Elastic Container Service)** or **EKS (Elastic Kubernetes Service)** instead, you could use the existing `/app/` folder directly without modifications. The serverless approach requires this Lambda-specific adaptation.

#### Root `/app/Dockerfile` (Local Development)
```dockerfile
# Simple Flask server
CMD ["python", "app.py"]
EXPOSE 8000
```
- Runs Flask development server
- Exposes port 8000 for local testing
- No Lambda dependencies
- **Could be used directly with ECS/EKS** without modifications

#### `terraform/app/Dockerfile` (Lambda Deployment)
```dockerfile
# Lambda Runtime Interface Client
RUN pip install --no-cache-dir awslambdaric
ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["app.lambda_handler"]
```
- Installs AWS Lambda Runtime Interface Client (`awslambdaric`)
- Uses Lambda-specific entrypoint
- Points to `lambda_handler` function
- **Does NOT expose Flask's `app.run()`** - preventing direct Flask server execution

### 3. **Security & Best Practices**

**Why we don't expose `app.run()` in Lambda:**

- ❌ Flask's built-in server (`app.run()`) is **not production-ready**
- ❌ Running Flask directly in Lambda bypasses API Gateway integration
- ✅ Using `lambda_handler` ensures proper event handling
- ✅ API Gateway manages routing, authentication, and rate limiting
- ✅ Lambda only processes requests through the handler interface

### 4. **Dependency Differences**

#### Root `/app/requirements.txt`
```
flask==3.0.0
```

#### `terraform/app/requirements.txt`
```
flask==3.0.0
serverless-wsgi==3.0.3
```

Lambda version includes `serverless-wsgi` to convert API Gateway events to WSGI format.

---

## Architecture Comparison

### Local Development (`/app/`)
```
Browser → http://localhost:8000 → Flask Server → app.py
```

### Lambda Deployment (`terraform/app/`)
```
Browser → API Gateway → Lambda (lambda_handler) → serverless-wsgi → Flask app → app.py
```

---

## Benefits of Separation

✅ **Clean separation of concerns** - Local dev vs Production deployment  
✅ **No accidental production issues** - Lambda can't run Flask dev server  
✅ **Independent updates** - Modify local app without affecting Lambda  
✅ **Proper Lambda integration** - Handler ensures correct event processing  
✅ **Security** - No exposed Flask development server in production  

---

## When to Modify Each Folder

### Modify `/app/` when:
- Testing locally with Docker
- Developing new features
- Debugging with Flask dev tools

### Modify `terraform/app/` when:
- Deploying to AWS Lambda
- Updating Lambda-specific configurations
- Changing production behavior

**Note:** Keep the core Flask logic (routes, business logic) synchronized between both versions. Only the deployment mechanism differs.

---

## Summary

We maintain separate folders because:
1. **Lambda requires a handler function** (`lambda_handler`)
2. **Different runtime requirements** (awslambdaric vs direct Flask)
3. **Security** - Prevents exposing Flask's development server in production
4. **Best practices** - Proper separation of local development and serverless deployment

This architecture ensures your local development remains simple while your Lambda deployment follows AWS best practices and security standards.
