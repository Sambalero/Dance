require 'Qt4'

class PracticeSetButtonWidget < Qt::Widget
#called by trainer.practice_routines
    attr_accessor :chosen_set, :practice_set_names


  def chosen_set
  @@chosen_set
  end

  def self.practice_set_names
  @@practice_set_names
  end

  def practice_set_button
  @practice_set_button
  end

  def initialize()
    super()
    setWindowTitle "CHOOSE A SET"
    resize 200, 180
    move 100, 300
    show
  end


  def init_ui()
    grid = Qt::GridLayout.new()

    i = 0
    for name in practice_set_names
      init_button(name)
      grid.addWidget(@practice_set_button, i, 0)
      i += 1
    end

    setLayout(grid)
  end

  def init_button(name)
    @practice_set_button = Qt::PushButton.new name, self
    @practice_set_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    connect(@practice_set_button, SIGNAL('clicked()')) {@@chosen_set = name
      $qApp.quit}
  end

  def self.run_qt(practice_set_names)
    app = Qt::Application.new ARGV
    choose_set = PracticeSetButtonWidget.new
    choose_set.practice_set_names = practice_set_names.push("Exit Program")
    choose_set.init_ui
    app.exec
    return choose_set.chosen_set

  end
end

#---------------------------------
class HowDidYouDoWidget < Qt::Widget
#called by trainer.suggest_routine
    attr_accessor :performance_rating

  def performance_rating
  @@performance_rating
  end

  def value()
    @slider.value
  end

  def slider
    @slider
  end

  def lcd
    @lcd
  end

  def initialize()
    super()
    setWindowTitle "HOW DID YOU DO?"
    resize 200, 300
    move 100, 300
    init_ui()
    show
  end

  def init_ui()

    @@performance_rating = 0   #if I initialize this to nil, I can use that value as not practiced.

    grid = Qt::GridLayout.new()

    @lcd = Qt::LCDNumber.new(2)
    @lcd.setSegmentStyle(Qt::LCDNumber::Filled)
    @lcd.setPalette(Qt::Palette.new(Qt::Color.new(250, 250, 200)))
    @lcd.setAutoFillBackground(true)
    @slider = Qt::Slider.new(Qt::Horizontal, self)
    @slider.setRange(0, 10)
    @slider.setValue(0)
    @next_button = Qt::PushButton.new "NEXT"
    @next_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    @quit_button = Qt::PushButton.new "EXIT PROGRAM"
    @quit_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))

    connect(@quit_button, SIGNAL('clicked()')) {@@quit = true #quit is not used, nor does it have an accessor
      $qApp.quit}
    connect(@next_button, SIGNAL('clicked()')) {@@next = true #next is not used, nor does it have an accessor
      $qApp.quit}
    connect(@slider, SIGNAL('valueChanged(int)'), @lcd, SLOT('display(int)'))
    connect(@slider, SIGNAL('valueChanged(int)')) {@@performance_rating = @slider.value}

    grid.addWidget(@lcd, 0, 0, 1, 2)
    grid.addWidget(@slider, 1, 0, 1, 2)
    grid.addWidget(@next_button, 2, 0)
    grid.addWidget(@quit_button, 2, 1)
    setLayout(grid)

  end

  def self.run_qt
    app = Qt::Application.new ARGV
    performance_rating = HowDidYouDoWidget.new #need a better name
    app.exec
    return performance_rating.performance_rating
  end
end



#-----------------------------------------------
class PracticeRoutineWidget < Qt::Widget
 #called by trainer.suggest_routine

 #the PracticeRoutineWidget offers an ordered list of routines to choose from, including "none" and "exit program"
 #each time a routine is practiced it should be deleted from the list ?maybe offer a re-run option?
 # the entire practice set is passed to it.
 # it returns a chosen routine
 # it needs a set-practiced flag to return and a routine-practiced flag that ?could be internal?

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
    setWindowTitle "CHOOSE A ROUTINE"
    resize 200, 180
    move 100, 300
    show
  end


  def init_ui()  #can I add a label feature to the layout? Maybe buttons to change values?
    grid = Qt::GridLayout.new()

    i = 0
    for routine in routines
      init_button(routine)
      grid.addWidget(@routine_button, i, 0)
      i += 1
    end

    done_button = Qt::PushButton.new 'None of These'
    connect(done_button, SIGNAL('clicked()')) {@@chosen_routine = 'none'
       $qApp.quit}
    grid.addWidget(done_button, i+1, 0)

    layout = Qt::VBoxLayout.new()
    layout.addLayout(grid)
    setLayout(layout)
  end

  def init_button(routine)
    @routine_button = Qt::PushButton.new routine.name, self
    @routine_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    connect(@routine_button, SIGNAL('clicked()')) {@@chosen_routine = routine
      $qApp.quit}
  end

  def self.run_qt(routines)
    done = false
    app = Qt::Application.new ARGV
    choose_routine = PracticeRoutineWidget.new
    choose_routine.routines = routines
    choose_routine.init_ui
    app.exec
    return choose_routine.chosen_routine

  end
end









