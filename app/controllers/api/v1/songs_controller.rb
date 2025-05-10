module Api
  module V1
    class SongsController < ApplicationController
      before_action :set_song, only: [ :show, :update, :destroy ]

      # GET /api/v1/songs
      def index
        @songs = Song.all
        render json: @songs
      end

      # GET /api/v1/songs/1
      def show
        render json: @song
      end

      # POST /api/v1/songs
      def create
        @song = Song.new(song_params)

        if @song.save
          render json: @song, status: :created
        else
          render json: @song.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/songs/1
      def update
        if @song.update(song_params)
          render json: @song
        else
          render json: @song.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/songs/1
      def destroy
        @song.destroy
        head :no_content
      end

      private

      # Método para obtener la canción por ID
      def set_song
        @song = Song.find(params[:id])
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: "Canción no encontrada" }, status: :not_found
      end

      # Parámetros permitidos
      def song_params
        params.require(:song).permit(
          :title, :artist, :album, :release_date, :duration,
          :genre, :likes, :plays, :cover_url, :audio_url, authors: []
        )
      end
    end
  end
end
