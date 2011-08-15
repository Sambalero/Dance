require 'Qt4'
class SetToDeleteWidget < Qt::Widget
 #called by trainer.suggest_set

 # the SetToDeleteWidget offers an ordered list of sets to choose from, including "none" and "exit program"
 # the sets array is passed to it.
 # it returns a new array of sets to delete, along with an exit flag

    attr_accessor :set_to_delete, :practice_set_names, :quit, :back
    # add back

  def self.quit
    @@quit
  end

  def self.back
    @@back
  end

  def set_to_delete
    @set_to_delete
  end

  def self.practice_set_names   #this probably could and should be an instance variable
    @@practice_set_names
  end

  def set_button #is this declaration necessary?
    @set_button
  end

  def initialize()
    super()
    setWindowTitle "DELETE WHICH SET?"
    resize 200, 180
    move 100, 300
    show
  end


  def init_ui()

    @@quit = false
    @@set_to_delete = nil

    grid = Qt::GridLayout.new()

    i = 0
    for set in practice_set_names
      init_button(set)
      grid.addWidget(@set_button, i, 0)
      i += 1
    end

    done_button = Qt::PushButton.new 'OK'
    connect(done_button, SIGNAL('clicked()')) {
       $qApp.quit}                     #
    grid.addWidget(done_button, i, 0)


    quit_button = Qt::PushButton.new 'Exit Program'
    connect(quit_button, SIGNAL('clicked()')) {@@quit = true
       $qApp.quit}
    grid.addWidget(quit_button, i+1, 0)

    back_button = Qt::PushButton.new 'BACK'
    connect(done_button, SIGNAL('clicked()')) {
      @set_to_delete = nil
      $qApp.quit}                     #what's up with this not working?
    grid.addWidget(back_button, i+2, 0)   #

    layout = Qt::VBoxLayout.new()
    layout.addLayout(grid)
    setLayout(layout)
  end

  def init_button(set)
    @set_button = Qt::PushButton.new set, self
    @set_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    connect(@set_button, SIGNAL('clicked()')) {@set_to_delete = set}
  end

  def self.run_qt(practice_set_names)
    done = false
    app = Qt::Application.new ARGV
    choose_set = SetToDeleteWidget.new
    choose_set.practice_set_names = practice_set_names
    choose_set.init_ui
    app.exec
    return choose_set.set_to_delete, quit
  end
end









