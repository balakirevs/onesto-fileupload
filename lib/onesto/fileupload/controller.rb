require 'onesto/fileupload/store'

module Onesto
  module Fileupload
    module Controller
      def create
        stored_file = Store.add(current_user.id, permitted_params[:file])
        render json: stored_file, status: :created
      end

      def destroy
        if Store.fetch(current_user.id, permitted_params[:id])
          Store.remove(current_user.id, permitted_params[:id])
          render_response(:no_content)
        else
          render_response(:not_found)
        end
      end

      private
      def permitted_params
        params.permit(:file, :id)
      end

      def render_response(status)
        file = permitted_params[:file].to_h
        if defined?(ActionDispatch::Http::UploadedFile) && file.is_a?(ActionDispatch::Http::UploadedFile)
          render nothing: true, status: status
        elsif defined?(Rack::Test::UploadedFile) && file.is_a?(Rack::Test::UploadedFile)
          render body: nil, status: status
        end
      end
    end
  end
end
