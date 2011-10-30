require 'Qt4'
require 'time'
class ChooseRoutineToPracticeWidget < Qt::Widget
 #called by trainer.practice_routines

 #the ChooseRoutineToPracticeWidget offers an ordered list of routines to choose from, including "none" and "exit program"
 # the entire practice set is passed to it.
 # it returns a chosen routine

attr_accessor :chosen_routine, :routines, :response

  def self.response
    @@response
  end

  def chosen_routine
    @@chosen_routine
  end

  def self.routines
    @@routines
  end

  def routine_button  #is this declaration necessary?
    @routine_button
  end

  def initialize()
    super()
    setWindowTitle "CHOOSE A ROUTINE TO PRACTICE"
    resize 200, 180
    move 10, 30
    show
  end


  def init_ui()

    @@response = ""
    @@chosen_routine = nil

    grid = Qt::GridLayout.new()

    i = 0
    maxRoutineRows = 15
    for routine in routines
      init_button(routine)
      if i<maxRoutineRows
        grid.addWidget(@routine_button, i, 0)
        grid.addWidget(@data_label, i, 1, 1, 3)
      else
        grid.addWidget(@routine_button, i-maxRoutineRows, 5)
        grid.addWidget(@data_label, i-maxRoutineRows, 6, 1, 3)
      end
      i += 1
    end

    done_button = Qt::PushButton.new 'Change Set (BACK)'
    connect(done_button, SIGNAL('clicked()')) {@@response = :back
       $qApp.quit}
    grid.addWidget(done_button, i, 0)

    add_routine_button = Qt::PushButton.new 'Add New Routine'
    connect(add_routine_button, SIGNAL('clicked()')) {@@response = :add_routine
       $qApp.quit}
    grid.addWidget(add_routine_button, i+1, 0)

    delete_routine_button = Qt::PushButton.new 'Delete Routine'
    connect(delete_routine_button, SIGNAL('clicked()')) {@@response = :delete_routine
       $qApp.quit}
    grid.addWidget(delete_routine_button, i+2, 0)

    edit_stats_button = Qt::PushButton.new 'Edit Stats'
    connect(edit_stats_button, SIGNAL('clicked()')) {@@response = :edit_routine
       $qApp.quit}
    grid.addWidget(edit_stats_button, i+3, 0)

    quit_button = Qt::PushButton.new 'Exit Program'
    connect(quit_button, SIGNAL('clicked()')) {@@response = :quit
       $qApp.quit}
    grid.addWidget(quit_button, i+4, 0)

    layout = Qt::VBoxLayout.new()
    layout.addLayout(grid)
    setLayout(layout)
  end

  def init_button(routine)
    @routine_button = Qt::PushButton.new routine.name, self
    @routine_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    connect(@routine_button, SIGNAL('clicked()')) {
      @@chosen_routine = routine
      @@response = :practice
      $qApp.quit}
    @pract_label = Qt::Label.new "#{routine.practice_count} Attempts"
    time = Time.parse(routine.last_date_practiced)
    @data_label = Qt::Label.new "#{routine.practice_count} Attempts, #{routine.success_count} Successful. Score: #{routine.score.round(2)}\nLast Practiced: #{time.strftime( '%x' )}"
  end

  def self.run_qt(routines)
    done = false
    app = Qt::Application.new ARGV
    choose_routine = ChooseRoutineToPracticeWidget.new
    choose_routine.routines = routines
    choose_routine.init_ui
    app.exec
    return choose_routine.chosen_routine, response

  end
end









