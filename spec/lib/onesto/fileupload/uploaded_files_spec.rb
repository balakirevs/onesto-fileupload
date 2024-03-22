require 'spec_helper'
require 'onesto/fileupload/uploaded_files'

RSpec.describe Onesto::Fileupload::UploadedFiles do
  let(:test_class) { Class.new do
    def self.after_action(*args)
    end

    include Onesto::Fileupload::UploadedFiles

    def current_user
      Struct.new(:id).new(1)
    end

    def response
      Struct.new(:status).new(200)
    end
  end
  }

  let(:test_class_instance) { test_class.new }

  describe 'inclusion' do
    it 'registers after_action callback' do
      a_class = Class.new do
        def self.after_action(*args)
        end
      end
      expect(a_class).to receive(:after_action).with(:clear_uploaded_files, only: [:create, :update], if: :response_ok?)
      a_class.send(:include, Onesto::Fileupload::UploadedFiles)
    end
  end

  describe 'uploaded_file' do
    it 'fetches file from store' do
      [sample_pdf_upload, sample_pdf_file_rack_test].each do |sample_file|
        file = Onesto::Fileupload::Store.add(1, sample_file)
        stored_file = Onesto::Fileupload::Store.fetch(1, file[:id])
        expect(test_class_instance.send(:uploaded_file, file)).to be(stored_file)
      end
    end
  end

  describe 'uploaded_file_param' do
    it 'returns a hash for rails params whitelisting' do
      expect(test_class_instance.send(:uploaded_file_param)).to eq({file: [:id]})
    end
  end

  describe 'clear_uploaded_files callback' do
    it 'clears files from store' do
      expect(Onesto::Fileupload::Store).to receive(:clear).with(1)
      test_class_instance.send(:clear_uploaded_files)
    end
  end
end
