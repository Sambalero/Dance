require 'Qt4'
class ConfirmDeleteWidget < Qt::Widget

attr_accessor :deletees, :confirmed
 #the MessageBoxWidget presents a message to the user
  def self.deletees
    @@deletees
  end

  def self.confirmed
    @@confirmed
  end

  def initialize()
    super()
    setWindowTitle ""
    resize 200, 180
    move 100, 300
    show
  end


  def init_ui()

    @@confirmed = :not

    grid = Qt::GridLayout.new()

    message = "This will delete: \n"
    @@deletees.each do |deletee|
      if deletee.class == Routine
        message = "#{message}\n  #{deletee.name}"
      else
        message = "#{message}\n  #{deletee}"
      end
    end
    message = "#{message}\n\nContinue?"

    @message_label = Qt::Label.new message
    grid.addWidget(@message_label, 0, 0)

    yes_button = Qt::PushButton.new 'YES'
    connect(yes_button, SIGNAL('clicked()')) {$qApp.quit
      @@confirmed = :confirmed}
    grid.addWidget(yes_button, 1, 0)

    no_button = Qt::PushButton.new 'NO'
    connect(no_button, SIGNAL('clicked()')) {$qApp.quit
      @@confirmed = :not}
    grid.addWidget(no_button, 1, 1)

    layout = Qt::VBoxLayout.new()
    layout.addLayout(grid)
    setLayout(layout)
  end

 #called by   trainer.delete_routine, trainer.delete_set
  def self.run_qt(deletees)
    app = Qt::Application.new ARGV
    confirm = ConfirmDeleteWidget.new
    @@deletees = deletees
    confirm.init_ui
    app.exec
    return confirmed
  end
end









