module Api
  module V1
    class AudiosController < ApplicationController
      def show
        grid_fs_file = Mongoid::GridFs.get(params[:id])
        self.response_body = grid_fs_file.data
        self.content_type = grid_fs_file.content_type
        response.headers['Content-Length'] = grid_fs_file.length.to_s
        response.headers['Last-Modified'] = grid_fs_file.upload_date.httpdate
      rescue Mongoid::Errors::DocumentNotFound
        head :not_found
      end
    end
  end
end