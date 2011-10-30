require 'Qt4'
class DeleteRoutineWidget < Qt::Widget
 #called by trainer.suggest_routine

 # the DeleteRoutineWidget offers an ordered list of routines to choose from, including "none" and "exit program"
 # the routines array is passed to it.
 # it returns a new array of routines to delete, along with an exit flag

    attr_accessor :routines_to_delete, :routines, :quit

  def self.status
    @@status
  end

  def self.quit
    @@quit
  end

  def routines_to_delete
    @@routines_to_delete
  end

  def self.routines
    @@routines
  end

  def routine_button #is this declaration necessary?
    @routine_button
  end

  def initialize()
    super()
    setWindowTitle "DELETE WHICH ROUTINE?"
    resize 200, 180
    move 10, 30
    show
  end


  def init_ui()

    @@status = ""
    @@quit = false
    @@routines_to_delete = []

    grid = Qt::GridLayout.new()

    i = 0
    for routine in routines
      init_button(routine)
      grid.addWidget(@routine_button, i, 0)
      i += 1
    end

    done_button = Qt::PushButton.new 'OK'
    connect(done_button, SIGNAL('clicked()')) {
       @@status = :done
       $qApp.quit}
    grid.addWidget(done_button, i, 0)


    quit_button = Qt::PushButton.new 'Exit Program'
    connect(quit_button, SIGNAL('clicked()')) {
      @@status = :quit
      $qApp.quit}
    grid.addWidget(quit_button, i+1, 0)

    back_button = Qt::PushButton.new 'Back'
    connect(back_button, SIGNAL('clicked()')) {
      @@status = :back
      $qApp.quit}
    grid.addWidget(back_button, i+2, 0)

    layout = Qt::VBoxLayout.new()
    layout.addLayout(grid)
    setLayout(layout)
  end

  def init_button(routine)
    @routine_button = Qt::PushButton.new routine.name, self
    @routine_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    connect(@routine_button, SIGNAL('clicked()')) {@@routines_to_delete.push(routine)}
  end

  def self.run_qt(routines)
    done = false
    app = Qt::Application.new ARGV
    choose_routine = DeleteRoutineWidget.new
    choose_routine.routines = routines
    choose_routine.init_ui
    app.exec
    return choose_routine.routines_to_delete, status
  end
end









