# Use a specific patch version for better reproducibility
FROM php:8.3-cli

# Combine all OS-level setup into a single RUN layer
# This reduces image size and build time
RUN set -eux; \
    apt-get update && apt-get upgrade -y; \
    # Install dependencies
    apt-get install -y --no-install-recommends \
        curl \
        git \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libxml2-dev \
        unzip \
        default-mysql-client; \
    # Install PHP extensions
    docker-php-ext-install zip gd xml pdo_mysql; \
    # Install Acquia CLI
    curl -fsSL https://github.com/acquia/cli/releases/latest/download/acli.phar -o /usr/local/bin/acli; \
    chmod +x /usr/local/bin/acli; \
    # Clean up
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set PHP memory limit (can be its own layer)
RUN echo "memory_limit = -1" > /usr/local/etc/php/conf.d/memory-limit.ini

# Set working directory
WORKDIR /app