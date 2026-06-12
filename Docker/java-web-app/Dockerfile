# ==========================================
# STAGE 1: Build Environment (Compiler Stage)
# ==========================================
FROM eclipse-temurin:17-jdk-alpine AS compiler

# Set temporary working directory
WORKDIR /build

# Copy the raw source code from host into the compiler stage
COPY App.java .

# Compile the raw Java code down to bytecode
RUN javac App.java

# ==========================================
# STAGE 2: Production Runtime State
# ==========================================
FROM eclipse-temurin:17-jre-alpine

# Set a secure production runtime path
WORKDIR /app

# THE CRITICAL FIX: Use a wildcard (*.class) to copy App.class AND App$1.class!
COPY --from=compiler /build/*.class .

# Document the internal port mapping reference
EXPOSE 8080

# Execute the application binary bytecode wrapper natively
CMD ["java", "App"]
