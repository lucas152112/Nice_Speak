# =====================================================
# Rust Backend Dockerfile
# =====================================================
# Build Stage
FROM rust:1.75-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache musl-dev openssl-dev pkgconfig

# Copy source code
COPY . .

# Build binary
RUN cargo build --release --target x86_64-unknown-linux-musl

# =====================================================
# Production Stage
FROM alpine:3.19

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache openssl curl ca-certificates

# Create non-root user
RUN addgroup -g 1000 app && \
    adduser -u 1000 -G app -s /bin/sh -D app

# Copy binary from builder
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/manage_backend /app/manage_backend
COPY --from=builder /app/.env.production /app/.env

# Create directories
RUN mkdir -p /app/logs && chown -R app:app /app

# Switch to non-root user
USER app

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Environment
ENV APP_ENV=production
ENV RUST_LOG=info

# Entry point
ENTRYPOINT ["./manage_backend"]
