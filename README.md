# Songs Microservice (songs-ms)

<!-- Este microservicio proporciona una API RESTful para gestionar información de canciones, permitiendo ver detalles como fecha de publicación, duración, género, autores, álbum al que pertenece, cantidad de me gusta y cantidad de reproducciones. -->

## Tecnologías

- Ruby on Rails (API)
- MongoDB (Base de datos)
- Docker & Docker Compose (Contenedorización)

## Endpoints de API

### GET /api/v1/songs
Lista todas las canciones disponibles.

### GET /api/v1/songs/:id
Muestra información detallada de una canción específica.

### POST /api/v1/songs
Crea una nueva canción.

### PATCH/PUT /api/v1/songs/:id
Actualiza información de una canción existente.

### DELETE /api/v1/songs/:id
Elimina una canción.

## Modelo de Datos

<!-- El modelo `Song` incluye los siguientes campos:

- `title`: Título de la canción
- `artist`: Artista principal
- `authors`: Array de autores de la canción
- `album`: Álbum al que pertenece
- `release_date`: Fecha de lanzamiento
- `duration`: Duración en formato "minutos:segundos"
- `genre`: Género musical
- `likes`: Cantidad de "me gusta"
- `plays`: Cantidad de reproducciones
- `cover_url`: URL de la imagen de portada
- `audio_url`: URL del archivo de audio -->

## Instalación y ejecución

### Usando Docker (recomendado)

<!-- 1. Asegúrate de tener Docker y Docker Compose instalados
2. Clona este repositorio
3. Ejecuta:
   ```bash
   docker-compose up
   ```
4. El servicio estará disponible en http://localhost:3001 -->

### Desarrollo local

<!-- 1. Instala Ruby (versión 3.2 o superior)
2. Instala MongoDB
3. Instala las dependencias:
   ```bash
   bundle install
   ```
4. Inicia el servidor:
   ```bash
   rails server -p 3001
   ``` -->

## Integración con front-end

<!-- Este microservicio está diseñado para integrarse con la aplicación frontend de Aleph, permitiendo visualizar la información detallada de las canciones según la historia de usuario. -->
