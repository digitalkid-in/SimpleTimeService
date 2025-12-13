FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \

    PYTHONUNBUFFERED=1


RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Working Directory
WORKDIR /app

# Install dependencies first (better layer caching)
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

EXPOSE 5000


CMD ["python", "app.py"]