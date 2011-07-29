require 'Qt4'


class EditRoutineWidget < Qt::Widget

#  Could the done label be used to get the new values? if so, can we disconnect all the slots below
# Would this be easier with Routine as an array?  done??? Refactor as a proper object?
#TODO format numeric output

    slots 'new_name(QString)', 'new_link(QString)', 'new_priority(QString)', 'new_practice_count(QString)', 'new_success_count(QString)', 'new_last_success_value(QString)'

    attr_accessor :routine, :nombre, :link, :priority, :practice_count, :success_count, :last_success_value

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

  def initialize()
      super()

      setWindowTitle "EDIT ROUTINE"

      resize 250, 150
      move 300, 300

      show
  end

  def init_ui()

    @@nombre = routine.name
    @@link = routine.link
    @@priority = routine.priority
    @@practice_count = routine.practice_count
    @@success_count = routine.success_count
    @@last_success_value = routine.last_success_value

    grid = Qt::GridLayout.new()

    done_button = Qt::PushButton.new self
    done_button.setText "DONE"
    done_button.resize 30, 20
    grid.addWidget(done_button, 0, 2)
    connect(done_button, SIGNAL('clicked()')) { $qApp.quit}

    info_button = Qt::PushButton.new self
    info_button.setText "Info"
    info_button.resize 30, 20
    grid.addWidget(info_button, 3, 1)
    connect(info_button, SIGNAL('clicked()')) {launch_priority_info}
#######################################
    header = Qt::Label.new(self)
    header.setText "Enter the new value in the box."
    header.setFont(Qt::Font.new('Times', 14, Qt::Font::Bold))
    grid.addWidget(header, 0, 0)    #span columns

    name_label = Qt::Label.new(self)
    name_label.setText "Name: #{routine.name}"
    @edit_name = Qt::LineEdit.new self
    connect @edit_name, SIGNAL("textChanged(QString)"),
            self, SLOT("new_name(QString)")
    grid.addWidget(name_label, 1, 0)
    grid.addWidget(@edit_name, 1, 2)

    link_label = Qt::Label.new(self)
    link_label.setText "Link: #{routine.link}"
    @edit_link = Qt::LineEdit.new self
    connect @edit_link, SIGNAL("textChanged(QString)"),
            self, SLOT("new_link(QString)")
    grid.addWidget(link_label, 2, 0)
    grid.addWidget(@edit_link, 2, 2)

    priority_label = Qt::Label.new(self)
    priority_label.setText "Priority: #{routine.priority}"
    @edit_priority = Qt::LineEdit.new self
    connect @edit_priority, SIGNAL("textChanged(QString)"),
            self, SLOT("new_priority(QString)")
    grid.addWidget(priority_label, 3, 0)
    grid.addWidget(@edit_priority, 3, 2)

    practice_count_label = Qt::Label.new(self)
    practice_count_label.setText "Times practiced: #{routine.practice_count}"
    @edit_practice_count = Qt::LineEdit.new self
    connect @edit_practice_count, SIGNAL("textChanged(QString)"),
            self, SLOT("new_practice_count(QString)")
    grid.addWidget(practice_count_label, 4, 0)
    grid.addWidget(@edit_practice_count, 4, 2)

    success_count_label = Qt::Label.new(self)
    success_count_label.setText "Successes: #{routine.success_count}"
    @edit_success_count = Qt::LineEdit.new self
    connect @edit_success_count, SIGNAL("textChanged(QString)"),
            self, SLOT("new_success_count(QString)")
    grid.addWidget(success_count_label, 5, 0)
    grid.addWidget(@edit_success_count, 5, 2)

    last_success_value_label = Qt::Label.new(self)
      success = routine.last_success_value == 0.1 ? "No" : "Yes"
    last_success_value_label.setText "Last practice successful? #{success}"
    @edit_last_success_value = Qt::LineEdit.new self
    connect @edit_last_success_value, SIGNAL("textChanged(QString)"),
            self, SLOT("new_last_success_value(QString)")
    grid.addWidget(last_success_value_label, 6, 0)
    grid.addWidget(@edit_last_success_value, 6, 2)

    score_label = Qt::Label.new(self)
    score_label.setText "Score: #{routine.score}"
    score_label2 = Qt::Label.new(self)
    score_label2.setText "Your score is recalculated by the program with each practice."
    grid.addWidget(score_label, 7, 0)
    grid.addWidget(score_label2, 7, 2)

    setLayout(grid)

  end

#######################################XXXXXX
# TODO need if nil or empty do what? (?)
  def new_name text
    if text != nil
      nombre = text.strip
      if not nombre.empty?
        @@nombre = @edit_name.text
      end
    end
  end

  def new_link text
    if text != nil
      link = text.strip
      if not link.empty?
        @@link = @edit_link.text
      end
    end
  end

    def new_priority text
    if text != nil
      priority = text.strip
      if (not priority.empty?) and is_numeric?(priority)
        @@priority = @edit_priority.text.to_f
      end
    end
  end

    def new_practice_count text
    if text != nil
      practice_count = text.strip
      if (not practice_count.empty?) and is_numeric?(practice_count)
        @@practice_count = @edit_practice_count.text.to_f
      end
    end
  end

    def new_success_count text
    if text != nil
      success_count = text.strip
      if (not success_count.empty?) and  is_numeric?(success_count)
        @@success_count = @edit_success_count.text.to_f
      end
    end
  end

    def new_last_success_value text
    if text != nil
      last_success_value = text.strip
      if (not last_success_value.empty?) and  is_numeric?(last_success_value)
        @@last_success_value = @edit_last_success_value.text.to_f
      end
    end
  end

  def launch_priority_info #called by init_ui
    fork do       #maybe this wants to be spawn?
      exec "open ~/prog/pract/practfiles/Priority.rtf"
    end
  end


  def self.run_qt(routine)
    app = Qt::Application.new ARGV
    edit_routine = EditRoutineWidget.new
    edit_routine.routine = routine
#    edit_routine.nombre = routine.nombre
#    edit_routine.link = routine.link
#    edit_routine.priority = routine.priority
#    edit_routine.practice_count = routine.practice_count
#    edit_routine.success_count = routine.success_count
#    edit_routine.last_success_value = routine.last_success_value
    edit_routine.init_ui
    app.exec
    return nombre, link, priority, practice_count, success_count, last_success_value
  end
end



