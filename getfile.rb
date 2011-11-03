require 'Qt4'
module GetFile
  def get_file
    file_name = nil
    app = Qt::Application.new(ARGV)
    f = Qt::FileDialog.new
    f.show()
    file_name = f.getOpenFileName()
    app.exec()
    if file_name then $qApp.quit end #this may be superfluous
   return file_name
  end
end
