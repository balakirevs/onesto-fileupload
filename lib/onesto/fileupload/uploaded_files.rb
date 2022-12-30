require 'onesto/fileupload/store'

module Onesto
  module Fileupload
    module UploadedFiles
      extend ActiveSupport::Concern

      included do
        after_filter :clear_uploaded_files, only: [:create, :update], if: :response_ok?
      end

      protected
      def uploaded_file(file)
        if file.is_a?(Hash)
          Store.fetch(current_user.id, file)
        else
          file
        end
      end

      def uploaded_file_param(param_name = :file)
        {param_name => [:id]}
      end

      private
      def clear_uploaded_files
        Store.clear(current_user.id)
      end

      def response_ok?
        "#{response.status}" =~ /\A2/
      end
    end
  end
end
