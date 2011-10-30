require 'Qt4'
class ButtonBoxWidget < Qt::Widget

attr_accessor :message, :response
 #this widget elicits a yes/no response from the user
  def self.message
    @@message
  end

  def self.response
    @@response
  end

  def initialize()
    super()
    setWindowTitle ""
    resize 200, 180
    move 100, 300
    show
  end


  def init_ui()

    @@response = :no

    grid = Qt::GridLayout.new()

    @message_label = Qt::Label.new @@message
    grid.addWidget(@message_label, 0, 0)

    yes_button = Qt::PushButton.new 'YES'
    connect(yes_button, SIGNAL('clicked()')) {$qApp.quit
      @@response = :yes}
    grid.addWidget(yes_button, 1, 0)

    no_button = Qt::PushButton.new 'NO'
    connect(no_button, SIGNAL('clicked()')) {$qApp.quit
      @@response = :no}
    grid.addWidget(no_button, 1, 1)

    layout = Qt::VBoxLayout.new()
    layout.addLayout(grid)
    setLayout(layout)
  end

 #called by NOTE  trainer.delete_routine, trainer.delete_set
  def self.run_qt(message)
    app = Qt::Application.new ARGV
    box = ButtonBoxWidget.new
    @@message = message
    box.init_ui
    app.exec
    return response
  end
end









