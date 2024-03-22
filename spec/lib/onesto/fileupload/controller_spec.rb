require 'spec_helper'
require 'onesto/fileupload/controller'
require 'action_controller'

RSpec.describe Onesto::Fileupload::Controller do
  let(:user) { Struct.new(:id).new(1) }
  let(:controller_class) { Class.new do
    include Onesto::Fileupload::Controller

    def initialize(params)
      @params = ActionController::Parameters.new(params)
    end

    private
    def render(*args)
    end

    def params
      @params
    end

    def current_user
      Struct.new(:id).new(1)
    end
  end }

  let(:controller) { controller_class.new(file: sample_pdf_upload, id: '123') }
  let(:controller_2) { controller_class.new(file: sample_pdf_file_rack_test, id: '123') }

  describe 'create' do
    it 'stores file' do
      expect(Onesto::Fileupload::Store).to receive(:add).with(1, kind_of(ActionDispatch::Http::UploadedFile))
      controller.send(:create)

      expect(Onesto::Fileupload::Store).to receive(:add).with(1, kind_of(Rack::Test::UploadedFile))
      controller_2.send(:create)
    end

    it 'renders json with stored file hash' do
      expect(controller).to receive(:render).with(json: kind_of(Hash), status: :created)
      controller.send(:create)

      expect(controller_2).to receive(:render).with(json: kind_of(Hash), status: :created)
      controller_2.send(:create)
    end
  end
end
