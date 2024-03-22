require 'spec_helper'
require 'onesto/fileupload/store'

RSpec.describe Onesto::Fileupload::Store do
  before(:each) { Onesto::Fileupload::Store.clear(1) }
  after(:each) { sample_pdf_tmpfile.unlink }

  describe 'add - ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile classes' do
    it 'file needs to have known class' do
      expect{
        Onesto::Fileupload::Store.add(1, nil)
      }.to raise_error(/has unknown class/)
    end

    it 'copies given file' do
      [sample_pdf_upload, sample_pdf_file_rack_test].each do |sample_file|
        file = Onesto::Fileupload::Store.add(1, sample_file)
        expect(Onesto::Fileupload::Store.fetch(1, file[:id])).not_to be(sample_file)
      end
    end
  end

  describe 'fetch - ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile classes' do
    it 'fetches file from store' do
      [sample_pdf_upload, sample_pdf_file_rack_test].each do |sample_file|
        file = Onesto::Fileupload::Store.add(1, sample_file)
        expect(Onesto::Fileupload::Store.fetch(1, file[:id])).to have_attributes(
          original_filename: 'sample.pdf',
          content_type: 'application/pdf'
        )
      end
    end

    it 'accepts hash' do
      file = Onesto::Fileupload::Store.add(1, sample_pdf_upload)
      expect(Onesto::Fileupload::Store.fetch(1, file)).to be_a(ActionDispatch::Http::UploadedFile)

      file = Onesto::Fileupload::Store.add(1, sample_pdf_file_rack_test)
      expect(Onesto::Fileupload::Store.fetch(1, file)).to be_a(Rack::Test::UploadedFile)
    end
  end

  describe 'clear - ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile classes' do
    it 'removes uploaded files' do
      file = Onesto::Fileupload::Store.add(1, sample_pdf_upload)
      expect(Onesto::Fileupload::Store).to receive(:remove).with(1, file[:id])
      Onesto::Fileupload::Store.clear(1)
    end
  end

  describe 'remove' do
    it 'unlinks stored file' do
      [sample_pdf_upload, sample_pdf_file_rack_test].each do |sample_file|
        file = Onesto::Fileupload::Store.add(1, sample_file)
        stored_file = Onesto::Fileupload::Store.fetch(1, file[:id])
        Onesto::Fileupload::Store.remove(1, file[:id])
        expect(stored_file.path).to be(nil)
      end
    end

    it 'removes uploaded file from files' do
      [sample_pdf_upload, sample_pdf_file_rack_test].each do |sample_file|
        file = Onesto::Fileupload::Store.add(1, sample_file)
        Onesto::Fileupload::Store.remove(1, file[:id])
        expect(Onesto::Fileupload::Store.fetch(1, file[:id])).to be(nil)
      end
    end
  end
end
