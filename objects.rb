class PracticeSet
  attr_accessor :name, :session_count, :routines

  def initialize(name, session_count, routines) #called by marshaller.marshal
    @name = name
    @session_count = session_count
    @routines = routines
  end

  def sort_routines_by_score #called by practice and by trainer.main
    @routines.map { |routine| routine.score = routine.calc_score(@session_count) }
    @routines.sort! { |a, b| a.score <=> b.score }
  end

end

#--------------------------------------------------------------------

class Routine

  attr_accessor :name, :link, :priority, :practice_count, :success_count, :last_routines_practice_count, :last_success_value, :last_date_practiced, :score

  def initialize (options) #called by marshaller.marshal_routine
    @name = options[:name]
    @link = options[:link]
    @priority = options[:priority]
    @practice_count = options[:practice_count]
    @success_count =  options[:success_count]
    @last_routines_practice_count = options[:last_routines_practice_count]
    @last_success_value = options[:last_success_value]
    @last_date_practiced = options[:last_date_practiced]
    @score = options[:score]
  end

  def calc_score(session_count) #called by practiceSet.sort_routines_by_score
    times_since_practiced_factor(session_count) * difficulty_factor * last_time_factor + @priority
  end

  def difficulty_factor #called by calc_score
    @practice_count != 0 ? 0.1+@success_count/@practice_count : 0.1
  end

  def times_since_practiced_factor(session_count) #called by calc_score
    1/(session_count - @last_routines_practice_count + 1)
  end

  def last_time_factor #called by calc_score
    @last_success_value == 0 ? 0.1 : 1.0
  end

  def index_practice_counts(session_count) #called by trainer.suggest_routine
    @practice_count += 1
    @last_routines_practice_count = session_count
  end

  def index_success_counts #called by trainer.suggest_routine
    @success_count +=1        #You didn't change anything here, right?
    @last_success_value = 1
  end
end

#--------------------------------------------------------------------

class PracticeRoutinesResponder

  attr_accessor :response

  def initialize(response)
    @response = response
  end

  def respond(chosen_routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process, trainer)
      return if response == :practice
      Quitter.new.exit(routines_in_process, initial_set_size, chosen_set, practice_sets) if response == :quit
      if response == :edit_routine then edit_routine(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process, trainer) end
      if response == :add_routine then add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size, trainer) end
      DeleteRoutineResponse.new.respond(chosen_routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process, trainer) if response == :delete_routine #yes?
      if response == :back then trainer.choose_set_to_practice(practice_sets, practice_set_names) end
  end

  def edit_routine(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process, trainer)
    routine = RoutineToEditWidget.run_qt(chosen_set.routines)
    trainer.edit_routine(routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
  end

  def add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size, trainer)
    trainer.add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size)
    trainer.practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
  end

end

#--------------------------------------------------------------------

class PracitceResponse      # How is this different from the above?
  def respond(chosen_routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process, trainer)
    return
  end
end


#--------------------------------------------------------------------

class DeleteRoutineResponse  #called by PracticeRoutinesResponder.respond
  def respond(chosen_routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process, trainer)
    trainer.delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)
    trainer.practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
  end
end

#--------------------------------------------------------------------

class Quitter

  def exit(routines_in_process, initial_set_size, chosen_set, practice_sets = []) #called by PracticeRoutinesResponder.respond
    chosen_set.session_count +=1 if routines_in_process.length < initial_set_size
    write_practice_sets practice_sets
  end

end

#--------------------------------------------------------------------

class SimplifiedTrainer

  def main #called at startup

    practice_sets, practice_set_names = get_practice_sets
    choose_set_to_practice(practice_sets, practice_set_names)
    choose_routine_to_practice
    practice_routines
    MessageBoxWidget.run_qt("Error: Returned to main at exit")

  end

  def choose_set_to_practice()
  end

  def choose_routine_to_practice()
  end

  def practice_routines()
  end

end

#--------------------------------------------------------------------

class ManageObjects

  def delete_set()
  end

  def edit_routine()
  end

  #...

end
