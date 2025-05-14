module Api
  module V1
    class CategoriesController < ApplicationController
      # GET /api/v1/categories
      def index
        # Obtener todas las categorías basadas en géneros existentes
        categories = MusicGenre.categories
        
        render json: categories
      end
      
      # GET /api/v1/categories/:id
      def show
        # Buscar la categoría por ID (slug)
        category_id = params[:id]
        
        # Buscar todos los géneros que pertenecen a esta categoría
        genres = MusicGenre.where(category: category_id.titleize)
        
        if genres.exists?
          # Construir respuesta
          category = {
            id: category_id,
            name: category_id.titleize,
            genres: genres.map do |genre|
              {
                id: genre.id.to_s,
                name: genre.name,
                slug: genre.slug,
                count: genre.count
              }
            end
          }
          
          # Agregar color según el nombre de la categoría
          category_colors = {
            'Pop' => 'from-pink-500 to-purple-500',
            'Hip Hop' => 'from-yellow-500 to-orange-500',
            'Rock' => 'from-red-500 to-red-800',
            'Electrónica' => 'from-blue-400 to-indigo-600',
            'R&B' => 'from-purple-400 to-purple-800',
            'Latina' => 'from-green-400 to-emerald-600',
            'Indie' => 'from-indigo-500 to-blue-800',
            'Jazz' => 'from-amber-400 to-yellow-800',
            'Metal' => 'from-gray-700 to-gray-900',
            'Clásica' => 'from-teal-400 to-teal-700',
            'Otros' => 'from-gray-400 to-gray-600'
          }
          
          category[:color] = category_colors[category[:name]] || 'from-gray-400 to-gray-600'
          
          render json: category
        else
          render json: { error: 'Categoría no encontrada' }, status: :not_found
        end
      end
    end
  end
end