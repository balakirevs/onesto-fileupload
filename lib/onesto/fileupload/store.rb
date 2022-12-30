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
          unless file.is_a?(ActionDispatch::Http::UploadedFile)
            throw "file #{file} has to be a ActionDispatch::Http::UploadedFile"
          end

          tmpfile = Tempfile.new(file.original_filename)
          tmpfile.set_encoding(Encoding::BINARY) if tmpfile.respond_to?(:set_encoding)
          tmpfile.binmode
          FileUtils.copy(file.path, tmpfile.path)
          ActionDispatch::Http::UploadedFile.new(
            tempfile: tmpfile,
            filename: file.original_filename,
            type: file.content_type,
            head: file.headers
          )
        end
      end
    end
  end
end
