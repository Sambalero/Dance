require 'Qt4'


class AddSetWidget < Qt::Widget

    slots 'on_changed(QString)'

    attr_accessor :new_set_name

    def self.new_set_name
      @new_set_name
    end

    def initialize
        super

        setWindowTitle "ADD A SET"

        init_ui

        resize 200, 150
        move 300, 300

        show
    end

    def init_ui

        @label = Qt::Label.new self    #self here puts the widget in the window
        @label.setText "Enter New Set Name"
        @label.adjustSize

        edit = Qt::LineEdit.new self
        connect edit, SIGNAL("textChanged(QString)"),
            self, SLOT("on_changed(QString)")

       @done_button = Qt::PushButton.new self
       @done_button.setText "OK"
       connect(@done_button, SIGNAL('clicked()')) { $qApp.quit}

        edit.move 30, 60
        @label.move 30, 20
        @done_button.move 100, 100

    end

    def on_changed text     #add validation ifs here...
      if text != nil
      name = text.strip
        if (not name.empty?)
          @new_set_name = name
        end
      end
    end


  def self.run_qt
    app = Qt::Application.new ARGV
    add_set = AddSetWidget.new
    app.exec
    return add_set.new_set_name
  end
end

