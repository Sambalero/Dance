require 'Qt4'


class AddSetWidget < Qt::Widget

    slots 'on_changed(QString)'

    attr_accessor :new_set_name, :back, :quit

    def self.new_set_name
      @new_set_name
    end

    def self.quit
      @@quit
    end

    def self.back
      @@back
    end

    def initialize
        super

        setWindowTitle "ADD A SET"

        init_ui

        resize 270, 200
        move 300, 300

        show
    end

    def init_ui

      @@back = false
      @@quit = false

        @label = Qt::Label.new self    #self here puts the widget in the window
        @label.setText "Enter New Set Name"
        @label.adjustSize

        edit = Qt::LineEdit.new self #Make edit wider
        connect edit, SIGNAL("textChanged(QString)"),
            self, SLOT("on_changed(QString)")

       @done_button = Qt::PushButton.new self
       @done_button.setText "OK"
       connect(@done_button, SIGNAL('clicked()')) { $qApp.quit}

       @back_button = Qt::PushButton.new self
       @back_button.setText "BACK"
       connect(@back_button, SIGNAL('clicked()')) {@@back = true, $qApp.quit}

       @quit_button = Qt::PushButton.new self
       @quit_button.setText "Exit Program"
       connect(@quit_button, SIGNAL('clicked()')) {@@quit = true, $qApp.quit}

        edit.move 30, 60
        @label.move 30, 20
        @done_button.move 120, 100
        @quit_button.move 30, 140
        @back_button.move 160, 140

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
    return add_set.new_set_name, back, quit
  end
end

