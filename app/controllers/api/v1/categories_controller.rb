module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        categories = get_categories

        render json: categories
      end

      private

      def get_categories
        # Agrupar géneros por la primera letra
        genres = MusicGenre.all.order_by(name: :asc)
        categories = {}

        genres.each do |genre|
          first_letter = genre.name[0].upcase
          
          # Inicializar la categoría si no existe
          categories[first_letter] ||= {
            id: first_letter.downcase,
            name: first_letter,
            genres: []
          }

          # Agregar el género a la categoría
          categories[first_letter][:genres] << {
            id: genre.id.to_s,
            name: genre.name,
            slug: genre.slug,
            count: genre.music_artists.count
          }
        end

        # Convertir el hash a un array de categorías
        categories.values
      end
    end
  end
end