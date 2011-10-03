require 'Qt4'
require 'time'
class ChooseRoutineToPracticeWidget < Qt::Widget
 #called by trainer.suggest_routine

 #the ChooseRoutineToPracticeWidget offers an ordered list of routines to choose from, including "none" and "exit program"
 # the entire practice set is passed to it.
 # it returns a chosen routine
 # it needs a set-practiced flag  TODO confirm
attr_accessor :chosen_routine, :routines

  def self.add_routine
    @@add_routine
  end

  def self.delete_routine
    @@delete_routine
  end

  def self.edit_stats
    @@edit_stats
  end

  def self.quit    #fixed?? quit should do what none does; none should allow us to start over
    @@quit
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
    move 100, 300
    show
  end


  def init_ui()

    @@add_routine = false
    @@delete_routine = false
    @@edit_stats = false
    @@quit = false
    @@chosen_routine = nil

    grid = Qt::GridLayout.new()

    i = 0
    for routine in routines
      init_button(routine)
      grid.addWidget(@routine_button, i, 0)
      grid.addWidget(@data_label, i, 1, 1, 3)
      i += 1
    end

    done_button = Qt::PushButton.new 'Change Set (BACK)'
    connect(done_button, SIGNAL('clicked()')) {@@chosen_routine = 'none'
       $qApp.quit}
    grid.addWidget(done_button, i, 0)

    add_routine_button = Qt::PushButton.new 'Add New Routine'
    connect(add_routine_button, SIGNAL('clicked()')) {@@add_routine = true
       $qApp.quit}
    grid.addWidget(add_routine_button, i+1, 0)

    delete_routine_button = Qt::PushButton.new 'Delete Routine'
    connect(delete_routine_button, SIGNAL('clicked()')) {@@delete_routine = true
       $qApp.quit}
    grid.addWidget(delete_routine_button, i+2, 0)

    edit_stats_button = Qt::PushButton.new 'Edit Stats'
    connect(edit_stats_button, SIGNAL('clicked()')) {@@edit_stats = true
       $qApp.quit}
    grid.addWidget(edit_stats_button, i+3, 0)

    quit_button = Qt::PushButton.new 'Exit Program'
    connect(quit_button, SIGNAL('clicked()')) {@@quit = true
       $qApp.quit}
    grid.addWidget(quit_button, i+4, 0)

    layout = Qt::VBoxLayout.new()
    layout.addLayout(grid)
    setLayout(layout)
  end

  def init_button(routine)
    since = (Time.now.to_i - routine.last_date_practiced.to_i)/60/24/60
    @routine_button = Qt::PushButton.new routine.name, self
    @routine_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    connect(@routine_button, SIGNAL('clicked()')) {@@chosen_routine = routine
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
    return choose_routine.chosen_routine, add_routine, delete_routine, edit_stats, quit

  end
end









