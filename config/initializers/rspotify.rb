# No autenticamos RSpotify automáticamente durante el arranque
# para evitar errores con credenciales. La autenticación se realizará
# bajo demanda cuando se use el servicio SpotifyService.

require 'rspotify'

# Configurar el API de RSpotify pero no autenticar todavía
RSpotify.instance_variable_set(:@client_id, nil)
RSpotify.instance_variable_set(:@client_secret, nil)