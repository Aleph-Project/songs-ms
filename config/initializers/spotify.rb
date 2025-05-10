# Configuración de credenciales para la API de Spotify
# 
# IMPORTANTE: Reemplaza estos valores con tus propias credenciales
# Para obtener credenciales de Spotify, visita: https://developer.spotify.com/dashboard/

require 'yaml'

# Definir la constante en el ámbito global
module SpotifyConfig
  # Carga variables de entorno si están disponibles (producción)
  if ENV['SPOTIFY_CLIENT_ID'] && ENV['SPOTIFY_CLIENT_SECRET']
    CONFIG = {
      client_id: ENV['SPOTIFY_CLIENT_ID'],
      client_secret: ENV['SPOTIFY_CLIENT_SECRET']
    }
  else
    # Usa credenciales de desarrollo local si existen
    begin
      if File.exist?(Rails.root.join('config', 'spotify_credentials.yml'))
        credentials = YAML.load_file(Rails.root.join('config', 'spotify_credentials.yml'))
        CONFIG = {
          client_id: credentials['client_id'],
          client_secret: credentials['client_secret']
        }
      else
        # Valores de ejemplo - reemplazar con tus propios valores
        CONFIG = {
          client_id: 'REEMPLAZAR_CON_TU_CLIENT_ID',
          client_secret: 'REEMPLAZAR_CON_TU_CLIENT_SECRET'
        }
        puts "⚠️  Advertencia: No se encontró el archivo de credenciales de Spotify."
        puts "   Crea el archivo config/spotify_credentials.yml con tus credenciales."
      end
    rescue => e
      puts "❌ Error al cargar credenciales de Spotify: #{e.message}"
      # Valores de respaldo
      CONFIG = {
        client_id: 'REEMPLAZAR_CON_TU_CLIENT_ID',
        client_secret: 'REEMPLAZAR_CON_TU_CLIENT_SECRET'
      }
    end
  end
end

# Crear una constante global para mantener compatibilidad con el código existente
SPOTIFY_CONFIG = SpotifyConfig::CONFIG