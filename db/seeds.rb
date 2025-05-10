# Solo borrar canciones y limpiar GridFS si no hay datos existentes (primera ejecución)
if Song.count == 0
  puts "Base de datos vacía. Creando canciones de ejemplo..."

  # Limpiar archivos de GridFS
  Mongo::Grid::FSBucket.new(Mongoid.default_client.database).files_collection.delete_many({})

  # Crear canciones de ejemplo
  songs_data = [
    {
      title: "Tití Me Preguntó",
      artist: "Bad Bunny",
      authors: [ "Benito Antonio Martínez Ocasio" ],
      album: "Un Verano Sin Ti",
      release_date: "2022-05-06",
      duration: "4:03",
      genre: "Reggaeton",
      likes: 2500000,
      plays: 15000000,
      cover_url: "/placeholder.svg?height=80&width=80"
    },
    {
      title: "Anti-Hero",
      artist: "Taylor Swift",
      authors: [ "Taylor Swift", "Jack Antonoff" ],
      album: "Midnights",
      release_date: "2022-10-21",
      duration: "3:20",
      genre: "Pop",
      likes: 1800000,
      plays: 12000000,
      cover_url: "/placeholder.svg?height=80&width=80"
    },
    {
      title: "Blinding Lights",
      artist: "The Weeknd",
      authors: [ "Abel Tesfaye", "Max Martin", "Oscar Holter" ],
      album: "After Hours",
      release_date: "2020-03-20",
      duration: "3:20",
      genre: "Synth-pop",
      likes: 3000000,
      plays: 20000000,
      cover_url: "/placeholder.svg?height=80&width=80"
    },
    {
      title: "Levitating",
      artist: "Dua Lipa",
      authors: [ "Dua Lipa", "Clarence Coffee Jr.", "Sarah Hudson", "Stephen Kozmeniuk" ],
      album: "Future Nostalgia",
      release_date: "2020-10-01",
      duration: "3:23",
      genre: "Disco-pop",
      likes: 2200000,
      plays: 18000000,
      cover_url: "/placeholder.svg?height=80&width=80"
    },
    {
      title: "Rojo",
      artist: "J Balvin",
      authors: [ "José Álvaro Osorio Balvín", "Sky Rompiendo" ],
      album: "Colores",
      release_date: "2020-03-19",
      duration: "3:10",
      genre: "Reggaeton",
      likes: 1200000,
      plays: 8000000,
      cover_url: "/placeholder.svg?height=80&width=80"
    },
    {
      title: "BREAK MY SOUL",
      artist: "Beyoncé",
      authors: [ "Beyoncé Knowles-Carter", "The-Dream", "Tricky Stewart", "Big Freedia" ],
      album: "Renaissance",
      release_date: "2022-07-29",
      duration: "4:38",
      genre: "House",
      likes: 1500000,
      plays: 10000000,
      cover_url: "/placeholder.svg?height=80&width=80"
    }
  ]

  songs_data.each do |song_data|
    Song.create!(song_data)
  end

  puts "#{Song.count} canciones de ejemplo creadas exitosamente"
else
  puts "Ya hay datos en la base de datos. Omitiendo la creación de datos de ejemplo."
end
