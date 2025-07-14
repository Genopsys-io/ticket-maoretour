# === Étape 1 : Base Composer avec PHP + extensions ===
FROM eu.gcr.io/www-genopsys/php-7.4 AS composer

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN apk update && apk add --no-cache \
    curl \
    unzip \
    git
WORKDIR /app

# === Étape 2 : Build de l'application avec les dépendances ===
FROM composer AS build

WORKDIR /app

# Copier les fichiers nécessaires pour installer les dépendances
COPY . .
# run composer, chmod files, setup laravel key
RUN sh -x ./scripts/setup


# === Étape 3 : Image finale pour exécution (runtime) ===
FROM eu.gcr.io/www-genopsys/php-7.4 AS app

WORKDIR /app

COPY --from=build /app /app

CMD ["php", "artisan", "queue:work", "--daemon"]
