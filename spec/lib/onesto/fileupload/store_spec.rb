require 'spec_helper'
require 'onesto/fileupload/store'

RSpec.describe Onesto::Fileupload::Store do
  before(:each) { Onesto::Fileupload::Store.clear(1) }
  after(:each) { sample_pdf_tmpfile.unlink }

  describe 'add' do
    it 'file needs to be a ActionDispatch::Http::UploadedFile' do
      expect{
        Onesto::Fileupload::Store.add(1, nil)
      }.to raise_error(/has to be a ActionDispatch::Http::UploadedFile/)
    end

    it 'copies given file' do
      file = Onesto::Fileupload::Store.add(1, sample_pdf_upload)
      expect(Onesto::Fileupload::Store.fetch(1, file[:id])).not_to be(sample_pdf_upload)
    end
  end

  describe 'fetch' do
    it 'fetches file from store' do
      file = Onesto::Fileupload::Store.add(1, sample_pdf_upload)
      expect(Onesto::Fileupload::Store.fetch(1, file[:id])).to have_attributes(
        original_filename: 'sample.pdf',
        content_type: 'application/pdf'
      )
    end

    it 'accepts hash' do
      file = Onesto::Fileupload::Store.add(1, sample_pdf_upload)
      expect(Onesto::Fileupload::Store.fetch(1, file)).to be_a(ActionDispatch::Http::UploadedFile)
    end
  end

  describe 'clear' do
    it 'removes uploaded files' do
      file = Onesto::Fileupload::Store.add(1, sample_pdf_upload)
      expect(Onesto::Fileupload::Store).to receive(:remove).with(1, file[:id])
      Onesto::Fileupload::Store.clear(1)
    end
  end

  describe 'remove' do
    it 'unlinks stored file' do
      file = Onesto::Fileupload::Store.add(1, sample_pdf_upload)
      stored_file = Onesto::Fileupload::Store.fetch(1, file[:id])
      Onesto::Fileupload::Store.remove(1, file[:id])
      expect(stored_file.path).to be(nil)
    end

    it 'removes uploaded file from files' do
      file = Onesto::Fileupload::Store.add(1, sample_pdf_upload)
      Onesto::Fileupload::Store.remove(1, file[:id])
      expect(Onesto::Fileupload::Store.fetch(1, file[:id])).to be(nil)
    end
  end
end
