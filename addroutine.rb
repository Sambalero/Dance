require 'Qt4'


class AddRoutine < Qt::Widget

    slots 'on_changed(QString)'

    attr_accessor :new_routine_name

    def self.new_routine_name
      @new_routine_name
    end

    def initialize
        super

        setWindowTitle "ADD A ROUTINE"

        init_ui

        resize 200, 150
        move 300, 300

        show
    end

    def init_ui

        @label = Qt::Label.new self    #self here puts the widget in the window
        @label.setText "Enter New Routine Name"
        @label.adjustSize

        edit = Qt::LineEdit.new self
        connect edit, SIGNAL("textChanged(QString)"),
            self, SLOT("on_changed(QString)")

       @done_button = Qt::PushButton.new self
       @done_button.setText "OK"
       connect(@done_button, SIGNAL('clicked()')) { $qApp.quit}

        edit.move 30, 60
        @label.move 25, 20
        @done_button.move 100, 100

    end

    def on_changed text
      @new_routine_name = text
    end

  def run_qt
    app = Qt::Application.new ARGV
    add_routine = AddRoutine.new
    app.exec
    return add_routine.new_routine_name
  end
end

