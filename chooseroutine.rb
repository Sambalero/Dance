require 'Qt4'


class ChooseRoutineWidget < Qt::Widget


    attr_accessor :chosen_routine, :routines

  def chosen_routine
    @@chosen_routine
  end

  def self.routines
    @@routines
  end

  def routine_button
    @routine_button
  end

    def initialize()
        super()

        setWindowTitle "EDIT ROUTINE"

        resize 250, 150
        move 300, 300

        show
    end

    def init_ui()
  #the done button isn't showing, but probably isn't needed, either
       @done_button = Qt::PushButton.new self
       @done_button.setText "OK"
       connect(@done_button, SIGNAL('clicked()')) { $qApp.quit}
        @done_button.move 100, 20

    grid = Qt::GridLayout.new()
    bg = Qt::ButtonGroup.new(self)

    @label = Qt::Label.new(self)
    @label.setText "Which routine do you want to edit?"
    @label.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    grid.addWidget(@label, 0, 0)

    i = 1
    for routine in routines
      init_button(routine)
      grid.addWidget(@routine_button, i, 0)
      bg.addButton(@routine_button)
      i += 1
    end

    setLayout(grid)

  end

  def init_button(routine)
     @routine_button = Qt::RadioButton.new(routine.name, self)
    @routine_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    connect(@routine_button, SIGNAL('clicked()')) {@@chosen_routine = routine
      $qApp.quit}
  end



def self.run_qt(routines)
app = Qt::Application.new ARGV
choose_routine = ChooseRoutineWidget.new
choose_routine.routines = routines
choose_routine.init_ui
app.exec
return choose_routine.chosen_routine
end
end


