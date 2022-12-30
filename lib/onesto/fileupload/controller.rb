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
          render nothing: true, status: :no_content
        else
          render nothing: true, status: :not_found
        end
      end

      private
      def permitted_params
        params.permit(:file, :id)
      end
    end
  end
end
