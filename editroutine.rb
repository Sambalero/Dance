require 'Qt4'


class EditRoutineWidget < Qt::Widget

#  Could the done label be used to get the new values? if so, can we disconnect all the slots below
# Would this be easier with Routine as an array?  done??? Refactor as a proper object?
#TODO format numeric output

    slots 'new_name(QString)', 'new_link(QString)', 'new_priority(QString)', 'new_practice_count(QString)', 'new_success_count(QString)', 'new_last_success_value(QString)'

    attr_accessor :routine, :nombre, :link, :priority, :practice_count, :success_count, :last_success_value, :status

  def self.status
    @@status
  end

  def self.routine
    @@routine
  end

  def self.nombre
    @@nombre
  end

  def self.link
    @@link
  end

  def self.priority
    @@priority
  end

  def self.practice_count
    @@practice_count
  end

  def self.success_count
    @@success_count
  end

  def self.last_success_value
    @@last_success_value
  end

  def slider
    @slider
  end

  def lcd
    @lcd
  end

  def name_label
    @name_label
  end

  def link_label
    @link_label
  end

  def practice_count_label
    @practice_count_label
  end

  def last_success_value_label
    @last_success_value_label
  end

  def success_count_label
    @success_count_label
  end

  def initialize()
      super()

      setWindowTitle "EDIT ROUTINE"

      resize 250, 150
      move 10, 30

      show
  end

  def init_ui()

    @@nombre = routine.name
    @@link = routine.link
    @@priority = routine.priority
    @@practice_count = routine.practice_count
    @@success_count = routine.success_count
    @@last_success_value = routine.last_success_value
    @@status = ""

    priorityText = "
      1: Need to brush up on this one!!!
      2: New - Want to get this perfect
      3: New
      4: Want to review this regularly
      5: Basics"


    header = Qt::Label.new(self)
    header.setText "Enter the new value in the box."
    header.setFont(Qt::Font.new('Times', 14, Qt::Font::Bold))

    @name_label = Qt::Label.new(self)
    @name_label.setText "Name: #{@@nombre}"
    @edit_name = Qt::LineEdit.new self
    @edit_name.setText routine.name
    connect @edit_name, SIGNAL("textChanged(QString)"),
            self, SLOT("new_name(QString)")

    @file_button = Qt::PushButton.new self
    @file_button.setText "GET FILE"
    connect(@file_button, SIGNAL('clicked()')) { @@status = :getFile
    $qApp.quit}

    @link_label = Qt::Label.new(self)
    @link_label.setText "Link: #{@@link}"
    @edit_link = Qt::LineEdit.new self
    @edit_link.setText routine.link
    connect @edit_link, SIGNAL("textChanged(QString)"),
            self, SLOT("new_link(QString)")

    @lcd = Qt::LCDNumber.new(2)
    @lcd.setSegmentStyle(Qt::LCDNumber::Filled)
    @lcd.setPalette(Qt::Palette.new(Qt::Color.new(250, 250, 200)))
    @lcd.setAutoFillBackground(true)
    @lcd.display(@@priority)

    @slider = Qt::Slider.new(Qt::Horizontal, self)
    @slider.setRange(1, 5)
    @slider.setValue(@@priority)
    connect(@slider, SIGNAL('valueChanged(int)'), @lcd, SLOT('display(int)'))
    connect(@slider, SIGNAL('valueChanged(int)')) {
      @@priority = @slider.value
      @message.setText "Set Priority with Slider: (Current Value: "  + @@priority.to_s + ")" + priorityText}

    @message = Qt::Label.new(self)
    @message.setText "Set Priority with Slider: (Current Value: "  + @@priority.to_s + ")" + priorityText
    @message.adjustSize

    @practice_count_label = Qt::Label.new(self)
    @practice_count_label.setText "Times practiced: #{@@practice_count}"
    @edit_practice_count = Qt::LineEdit.new self
    connect @edit_practice_count, SIGNAL("textChanged(QString)"),
            self, SLOT("new_practice_count(QString)")

    @success_count_label = Qt::Label.new(self)
    @success_count_label.setText "Successes: #{@@success_count}"
    @edit_success_count = Qt::LineEdit.new self
    connect @edit_success_count, SIGNAL("textChanged(QString)"),
            self, SLOT("new_success_count(QString)")

    @last_success_value_label = Qt::Label.new(self)
      success = @@last_success_value == 0.1 ? "No" : "Yes"
    @last_success_value_label.setText "Last practice successful? #{success}"
    last_success_button = Qt::PushButton.new self
    last_success_button.setText "CHANGE"
    last_success_button.resize 30, 20
    connect(last_success_button, SIGNAL('clicked()')) {

    @@success_count = @@last_success_value == 0.1 ? @@success_count + 1 : @@success_count
    @@last_success_value = @@last_success_value == 0.1 ? 1 : 0.1
    success = @@last_success_value == 0.1 ? "No" : "Yes"
    @last_success_value_label.setText "Last practice successful? #{success}"
    @success_count_label.setText "Successes: #{@@success_count}"}

    back_button = Qt::PushButton.new self
    back_button.setText "BACK"
    back_button.resize 30, 20
    connect(back_button, SIGNAL('clicked()')) { $qApp.quit
      @@status = :back }

    exit_button = Qt::PushButton.new self
    exit_button.setText "EXIT PROGRAM"
    exit_button.resize 30, 20
    connect(exit_button, SIGNAL('clicked()')) { $qApp.quit
      @@status = :quit }

    done_button = Qt::PushButton.new self
    done_button.setText "OK"
    done_button.resize 30, 20
#    done_button.setPalette( Qt::red )
    connect(done_button, SIGNAL('clicked()')) { $qApp.quit
      @@status = :done }

    grid = Qt::GridLayout.new()   # Here I have the layout info associated with the functional blocks; I think I like the layout grouped separately better.
    grid.addWidget(header, 0, 0, 1, 3)
    grid.addWidget(name_label, 1, 0, 1, 3)
    grid.addWidget(@edit_name, 2, 0, 1, 3)
    grid.addWidget(link_label, 3, 0, 1, 3)
    grid.addWidget(@file_button, 4, 0, 1, 3) #######################
    grid.addWidget(@edit_link, 5, 0, 1, 3)
    grid.addWidget(@lcd, 6, 2)
    grid.addWidget(@slider, 7, 2)
    grid.addWidget(@message, 6, 0, 3, 2)
    grid.addWidget(practice_count_label, 9, 0)
    grid.addWidget(@edit_practice_count, 9, 2)
    grid.addWidget(success_count_label, 10, 0)
    grid.addWidget(@edit_success_count, 10, 2)
    grid.addWidget(last_success_value_label, 11, 0)
    grid.addWidget(last_success_button, 11, 2)
    grid.addWidget(back_button, 12, 0)
    grid.addWidget(exit_button, 12, 1)
    grid.addWidget(done_button, 12, 2)
    setLayout(grid)

  end

# TODO need if nil or empty do what? (?)
  def new_name text
    if text != nil
      nombre = text.strip
      if not nombre.empty?
        @@nombre = @edit_name.text
        @name_label.setText "Name: #{@@nombre}"
      end
    end
  end

  def new_link text
    if text != nil
      link = text.strip
      if not link.empty?
        @@link = @edit_link.text
        @link_label.setText "Link: #{@@link}"
      end
    end
  end

  def new_practice_count text
    if text != nil
      practice_count = text.strip
      if (not practice_count.empty?) and is_numeric?(practice_count)
        @@practice_count = @edit_practice_count.text.to_f
        @practice_count_label.setText "Times practiced: #{@@practice_count}"
      end
    end
  end

  def new_success_count text
    if text != nil
      success_count = text.strip
      if (not success_count.empty?) and  is_numeric?(success_count)
        @@success_count = @edit_success_count.text.to_f
        @success_count_label.setText "Successes: #{@@success_count}"
      end
    end
  end

  def self.run_qt(routine)
    app = Qt::Application.new ARGV
    edit_routine = EditRoutineWidget.new
    edit_routine.routine = routine
    edit_routine.init_ui
    app.exec
    return nombre, link, priority, practice_count, success_count, last_success_value, status
  end
end



