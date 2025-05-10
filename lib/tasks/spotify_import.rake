namespace :spotify do
  desc 'Importar álbumes desde Spotify'
  task :import_albums, [:query, :limit] => :environment do |task, args|
    query = args[:query] || 'Bad Bunny'
    limit = (args[:limit] || 5).to_i
    
    puts "Importando álbumes de Spotify con la consulta: '#{query}' (límite: #{limit})..."
    
    # Obtener las credenciales de Spotify de la configuración centralizada
    client_id = SPOTIFY_CONFIG[:client_id]
    client_secret = SPOTIFY_CONFIG[:client_secret]
    
    begin
      # Inicializar el servicio de Spotify
      spotify_service = SpotifyService.new(client_id, client_secret)
      
      # Importar álbumes según la consulta
      result = spotify_service.import_albums_by_query(query, limit)
      
      if result[:total] > 0
        puts "✅ Se importaron #{result[:total]} álbumes exitosamente:"
        result[:albums].each_with_index do |album, index|
          puts "   #{index + 1}. #{album}"
        end
      else
        puts "ℹ️ No se encontraron álbumes nuevos para importar con la consulta: '#{query}'"
      end
    rescue => e
      puts "❌ Error al importar álbumes: #{e.message}"
    end
  end
end