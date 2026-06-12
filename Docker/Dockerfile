# =========================================================
# STAGE 1: The Build Environment (Heavy & Feature-Rich)
# =========================================================
# We name this stage "builder" so we can reference it later
FROM golang:1.22-alpine AS builder

# Set the working directory inside the compiler stage
WORKDIR /app

# Copy the source code from the host machine into the builder image
COPY . .

# Run the compiler binary tool to generate a single executable file named "myapp"
RUN go build -o myapp main.go


# =========================================================
# STAGE 2: The Production Runtime (Ultra-Lightweight & Secure)
# =========================================================
# We start completely fresh with a clean, tiny base image
FROM alpine:3.19

# Set a secure production runtime path
WORKDIR /production

# THE MAGIC STEP: Copy the compiled binary from the "builder" stage
# This pulls ONLY the executable file, leaving the Go SDK and compilers behind!
COPY --from=builder /app/myapp .

# Expose the production traffic port
EXPOSE 8080

# Configure the container to execute your lightweight application binary
CMD ["./myapp"]