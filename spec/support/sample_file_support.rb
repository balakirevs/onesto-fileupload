require 'action_dispatch'

module SampleFileSupport
  def sample_pdf_path
    Pathname.new(File.join(File.dirname(__FILE__), '..', 'files', 'sample.pdf'))
  end

  def sample_pdf_upload
    ActionDispatch::Http::UploadedFile.new(
      tempfile: sample_pdf_tmpfile,
      filename: 'sample.pdf',
      type: 'application/pdf',
      head: {}
    )
  end

  def sample_pdf_tmpfile
    tmpfile = Tempfile.new("sample.pdf")
    tmpfile.binmode
    FileUtils.copy(sample_pdf_path, tmpfile.path)
    tmpfile
  end
end
