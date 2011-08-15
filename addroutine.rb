require 'Qt4'


class AddRoutineWidget < Qt::Widget

    slots 'on_changed(QString)', 'theTextChanged()'

    attr_accessor :new_routine_name, :new_routine_link, :back, :quit, :priority

    def self.new_routine_name
      @new_routine_name
    end  #10

    def self.new_routine_link
      @new_routine_link
    end  #10

    def self.quit
      @@quit
    end  #10

    def self.back
      @@back
    end  #10

    def self.priority
      @@priority
    end  #10

  def slider
    @slider
  end

  def lcd
    @lcd
  end

    def initialize(parent = nil)
    super(parent)

        setWindowTitle "ADD A ROUTINE"

        init_ui

        resize 200, 150
        move 300, 300

        show
    end  #14

    def init_ui
      @@back = false
      @@quit = false
      @@priority = 1

        @name_label = Qt::Label.new self    #self here puts the widget in the window
        @name_label.setText "Enter New Routine Name"
        @name_label.adjustSize

        edit = Qt::LineEdit.new self
        connect edit, SIGNAL("textChanged(QString)"),
            self, SLOT("on_changed(QString)")



        @link_label = Qt::Label.new self    #self here puts the widget in the window
        @link_label.setText "Cut and Paste, or Type Link, File Path, or Routine Description"
        @link_label.adjustSize

    @textedit = Qt::TextEdit.new(self)
    @textedit.setWordWrapMode(Qt::TextOption::WordWrap)
    @textedit.setFont( Qt::Font.new("Times", 24) )

    connect(@textedit, SIGNAL('textChanged()'), self, SLOT('theTextChanged()'))

    @lcd = Qt::LCDNumber.new(2)
    @lcd.setSegmentStyle(Qt::LCDNumber::Filled)
    @lcd.setPalette(Qt::Palette.new(Qt::Color.new(250, 250, 200)))
    @lcd.setAutoFillBackground(true)
    @slider = Qt::Slider.new(Qt::Horizontal, self)
    @slider.setRange(0, 5)
    @slider.setValue(0)
    connect(@slider, SIGNAL('valueChanged(int)'), @lcd, SLOT('display(int)'))
    connect(@slider, SIGNAL('valueChanged(int)')) {@@priority = @slider.value}

        @priority_label = Qt::Label.new self
        @priority_label.setText "Set Priority With Slider"
        @priority_label.adjustSize

            #  http://flylib.com/books/en/2.491.1.168/1/
       @done_button = Qt::PushButton.new self
       @done_button.setText "OK"
       connect(@done_button, SIGNAL('clicked()')) { $qApp.quit}

       @back_button = Qt::PushButton.new self
       @back_button.setText "BACK"
       connect(@back_button, SIGNAL('clicked()')) {@@back = true, $qApp.quit}

       @quit_button = Qt::PushButton.new self
       @quit_button.setText "Exit Program"
       connect(@quit_button, SIGNAL('clicked()')) {@@quit = true, $qApp.quit}

       box = Qt::VBoxLayout.new
    box.addWidget(@name_label)
    box.addWidget(edit)
    box.addWidget(@link_label)
    box.addWidget(@textedit)
    box.addWidget(@priority_label)
    box.addWidget(@slider)
    box.addWidget(@lcd)
    box.addWidget(@done_button)
    box.addWidget(@back_button)
    box.addWidget(@quit_button)
    setLayout(box)
#        edit.move 30, 60      #consider layout
#        @name_label.move 25, 20
#        @done_button.move 100, 100

    end #27

    def on_changed text
      @new_routine_name = text
    end    #58

    def theTextChanged
      @new_routine_link = @textedit.toPlainText
    end    #62

  def self.run_qt #called by ...
    app = Qt::Application.new ARGV
    add_routine = AddRoutineWidget.new
    app.exec
    return add_routine.new_routine_name, add_routine.new_routine_link, back, quit,  priority
  end
end

