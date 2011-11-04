require 'Qt4'

class StatusButton < Qt::PushButton
  attr_accessor :status, :label, :quit

  def self.status
    @status
  end

  def self.label
    @label
  end

  def self.quit
    @quit
  end

  def initialize(label, status = "") #called by marshaller.marshal
    @label = label
    @status = status
    @quit = :no
    status_button = Qt::PushButton.new @label
    connect(status_button, SIGNAL('clicked()')) {
      @quit = :yes
      @status = status}
  return quit, status
  end
end

##-------------------------------------------------------------------- class Routine
#  attr_accessor :name, :link, :priority, :practice_count, :success_count, :last_routines_practice_count, :last_success_value, :last_date_practiced, :score
#
#  def initialize (options) #called by marshaller.marshal_routine
#    @name = options[:name]
#    @link = options[:link]
#    @priority = options[:priority]
#    @practice_count = options[:practice_count]
#    @success_count =  options[:success_count]
#    @last_routines_practice_count = options[:last_routines_practice_count]
#    @last_success_value = options[:last_success_value]
#    @last_date_practiced = options[:last_date_practiced]
#    @score = options[:score]
#  end
#
#  def calc_score(session_count) #called by practiceSet.sort_routines_by_score
#    times_since_practiced_factor(session_count) * difficulty_factor * last_time_factor + @priority
#  end
#
#  def difficulty_factor #called by calc_score
#    @practice_count != 0 ? 0.1+@success_count/@practice_count : 0.1
#  end
#
#  def times_since_practiced_factor(session_count) #called by calc_score
#    1/(session_count - @last_routines_practice_count + 1)
#  end
#
#  def last_time_factor #called by calc_score
#    @last_success_value == 0 ? 0.1 : 1.0
#  end
#
#  def index_practice_counts(session_count) #called by trainer.suggest_routine
#    @practice_count += 1
#    @last_routines_practice_count = session_count
#  end
#
#  def index_success_counts #called by trainer.suggest_routine
#	  @success_count +=1
#	  @last_success_value = 1
#  end
#end
#
##--------------------------------------------------------------------
#
#class PracticeRoutinesResponder
#
## have some issues with methods below
#
#  attr_accessor :response
#
#  def initialize(response)
#    @response = response
#  end
#
#  def respond(chosen_routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process, trainer)
#      if response == :practice then return end
#      if response == :quit then trainer.index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
#      if response == :edit_routine then edit_routine(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process, trainer) end
#      if response == :add_routine then add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size, trainer) end
#      if response == :delete_routine then delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names, trainer) end
#      if response == :back then trainer.choose_set_to_practice(practice_sets, practice_set_names) end
#  end
#
#  def edit_routine(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process, trainer)
#    routine = RoutineToEditWidget.run_qt(chosen_set.routines)
#    trainer.edit_routine(routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
#  end
#
#  def add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size, trainer)
#    trainer.add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size)
#    trainer.practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
#  end
#
#  def delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names, trainer)
#    trainer.delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)
#    trainer.practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
#  end
#
#end
