require 'action_dispatch'

module Onesto
  module Fileupload
    class Store
      class << self
        def add(key, file)
          copy = copy_file(file)
          id = file_id(copy)

          files(key)[id] = copy
          {id: id}
        end

        def fetch(key, id)
          if id.is_a?(Hash)
            files(key)[id[:id]]
          else
            files(key)[id]
          end
        end

        def clear(key)
          files(key).keys.each{|id| remove(key, id)}
        end

        def remove(key, id)
          file = fetch(key, id)
          files(key).delete(id)
          file.tempfile.unlink
        end

        private
        def files(key)
          @files ||= {}
          @files[key] ||= {}
        end

        def file_id(file)
          file.hash.to_s
        end

        def copy_file(file)
          validate_file!(file)

          tmpfile = create_tempfile(file)
          FileUtils.copy(file.path, tmpfile.path)

          build_uploaded_file(file, tmpfile)
        end

        private

        def validate_file!(file)
          if defined?(ActionDispatch::Http::UploadedFile) && file.is_a?(ActionDispatch::Http::UploadedFile)
            ActionDispatch::Http::UploadedFile
          elsif defined?(Rack::Test::UploadedFile) && file.is_a?(Rack::Test::UploadedFile)
            Rack::Test::UploadedFile
          else
            throw "file #{file} has unknown class"
          end
        end

        def create_tempfile(file)
          tmpfile = Tempfile.new(file.original_filename)
          tmpfile.set_encoding(Encoding::BINARY) if tmpfile.respond_to?(:set_encoding)
          tmpfile.binmode
          tmpfile
        end

        def build_uploaded_file(file, tmpfile)
          if defined?(ActionDispatch::Http::UploadedFile) && file.is_a?(ActionDispatch::Http::UploadedFile)
            ActionDispatch::Http::UploadedFile.new(
              tempfile: tmpfile,
              filename: file.original_filename,
              type: file.content_type,
              head: file.headers
            )
          elsif defined?(Rack::Test::UploadedFile) && file.is_a?(Rack::Test::UploadedFile)
            Rack::Test::UploadedFile.new(
              tmpfile.path,
              file.content_type,
              true,
              original_filename: file.original_filename
            )
          else
            raise 'Unsupported file type'
          end
        end
      end
    end
  end
end
