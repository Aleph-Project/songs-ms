FROM ruby:3.2

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Configurar variables de entorno
ENV RAILS_ENV=development
ENV MONGODB_URI=mongodb://mongo:27017/songs_ms
ENV BUNDLE_PATH=/usr/local/bundle
ENV PATH="/app/bin:${PATH}"

# Copiar los archivos de dependencias
COPY Gemfile Gemfile.lock ./

# Instalar las gemas incluyendo desarrollo y test
RUN bundle install

# Copiar el resto de la aplicación
COPY . .

# Asegurar que los scripts tengan permisos de ejecución
RUN chmod +x ./bin/* && \
    chmod +x ./bin/docker-entrypoint

# Exponer el puerto
EXPOSE 3001

# Script de inicio
ENTRYPOINT ["./bin/docker-entrypoint"]

# Comando para iniciar el servidor
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3001"]