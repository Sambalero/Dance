require 'Qt4'

class AddRoutineWidget < Qt::Widget

  slots 'on_changed(QString)', 'theTextChanged()'

  attr_accessor :status, :priority, :nombre, :link

  def self.nombre
    @@name
  end

  def self.link
    @@link
  end

  def self.status
    @@status
  end

  def self.priority
    @@priority
  end

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
      move 10, 30

      show
  end

  def init_ui
    @@status = ""
    @@priority = 1

    @name_label = Qt::Label.new self    #self here puts the widget in the window
    @name_label.setText "Enter New Routine Name"
    @name_label.adjustSize

    edit = Qt::LineEdit.new self
    edit.text = @@nombre
    connect edit, SIGNAL("textChanged(QString)"),
        self, SLOT("on_changed(QString)")

    priorityText = "
      1: Need to brush up on this one!!!
      2: New - Want to get this perfect
      3: New - Want to add this to our repertoire
      4: Want to review this regularly
      5: Basics"

    @link_label = Qt::Label.new self
    @link_label.setText "Or Type, or Cut and Paste
    Link or Routine Description Here:"
    @link_label.adjustSize

    @message = Qt::Label.new(self)
    @message.setText "Priority: " + priorityText
    @message.adjustSize

    @textedit = Qt::TextEdit.new(self)
    @textedit.setWordWrapMode(Qt::TextOption::WordWrap)
    @textedit.setFont( Qt::Font.new("Times", 24) )
    @textedit.setText @@link
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

    @file_button = Qt::PushButton.new self
    @file_button.setText "GET FILE"
    connect(@file_button, SIGNAL('clicked()')) { @@status = :getFile
    $qApp.quit}

    @done_button = Qt::PushButton.new self
    @done_button.setText "OK"
    connect(@done_button, SIGNAL('clicked()')) { @@status = :done
    $qApp.quit}

    @back_button = Qt::PushButton.new self
    @back_button.setText "BACK"
    connect(@back_button, SIGNAL('clicked()')) {@@status = :back
    $qApp.quit}

    @quit_button = Qt::PushButton.new self
    @quit_button.setText "Exit Program"
    connect(@quit_button, SIGNAL('clicked()')) {@@status = :quit
    $qApp.quit}

    box = Qt::VBoxLayout.new
      box.addWidget(@name_label)
      box.addWidget(edit)
      box.addWidget(@file_button)
      box.addWidget(@link_label)
      box.addWidget(@textedit)
      box.addWidget(@priority_label)
      box.addWidget(@slider)
      box.addWidget(@lcd)
      box.addWidget(@message)
      box.addWidget(@done_button)
      box.addWidget(@back_button)
      box.addWidget(@quit_button)
    setLayout(box)
  end

  def on_changed text
    @@nombre = text
  end

  def theTextChanged
    @@link = @textedit.toPlainText
  end

  def self.run_qt(name = "", link = "", priority = 1) #called by ...
    @@nombre = name
    @@link = link
    app = Qt::Application.new ARGV
    add_routine = AddRoutineWidget.new
    app.exec
    return @@nombre, @@link, status, priority
  end


end

