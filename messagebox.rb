require 'Qt4'
class MessageBoxWidget < Qt::Widget
  #the MessageBoxWidget presents a message to the user

  attr_accessor :message

  def self.message
    @@message
  end

  def initialize()
    super()
    setWindowTitle ""
    resize 200, 180
    move 10, 30
    show
  end


  def init_ui()

    grid = Qt::GridLayout.new()


    @message_label = Qt::Label.new message
    grid.addWidget(@message_label, 0, 0)

    done_button = Qt::PushButton.new 'OK'
    connect(done_button, SIGNAL('clicked()')) {$qApp.quit}
    grid.addWidget(done_button, 1, 0)

    layout = Qt::VBoxLayout.new()
    layout.addLayout(grid)
    setLayout(layout)
  end

 #called by   trainer.new_set
  def self.run_qt(message)
    app = Qt::Application.new ARGV
    message_box = MessageBoxWidget.new
    message_box.message = message
    message_box.init_ui
    app.exec
    return
  end
end









