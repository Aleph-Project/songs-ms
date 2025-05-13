namespace :genres do
  desc "Migrar los géneros de los artistas existentes a la colección MusicGenre"
  task migrate: :environment do
    puts "Iniciando migración de géneros..."
    
    # Contador para estadísticas
    artist_count = 0
    genre_count = 0
    
    # Recorrer todos los artistas
    MusicArtist.all.each do |artist|
      if artist.genres.present?
        artist.update_music_genres
        artist_count += 1
        genre_count += artist.genres.length
      end
    end
    
    # Mostrar estadísticas
    puts "Migración completada!"
    puts "Se procesaron los géneros de #{artist_count} artistas"
    puts "Se crearon o actualizaron #{MusicGenre.count} géneros únicos"
    puts "Total de asociaciones artista-género: #{genre_count}"
  end
end
