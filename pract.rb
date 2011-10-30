# This program will
#maybe we create the file if it doesn't already exist
# 0. load the practice_sets file into an array of arrays
# 1. display a list of practice sets to choose from
# 2. ask the user which practice set he wants to do
# 4. calculate a recommended practice sequence for this practice session
#    (i.e. prioritize the routines list)
# 5. display the recommended practice sequence to the user
# 5a. each item in the sequence should have a link to a file describing what it is (this could be a text file or a video, or a set of videos in a folde:c)
# 5b. each item in the sequence should have an opportunity for the user to input information (whether the user practiced it, whether the practice was successful, maybe a rating of how successful the practice was, maybe whether the practice was videorecorded)
# 5c. it might be nice to tell the user statistical stuff about the practice history of that routine
#6 enable the user to quit the program
#7 save the user input for the next session
#-----------------------------------------------------------------------------------------------
#File Format
#number of sets = sets.length => used by marshal
#practicesets = array of practice set objects
#  PracticeSet objects
#    set name = set.name
#    number of practice sessions = set.practice_count
#    number of routines = set.routines.length => used by marshal
#    [set of routines] = set.routines[0...routine_count]
#    #Routine objects
#	      name, = set.routines[i].name
#	      link, = set.routines[i].link
#	      priority  = set.routines[i].priority
#	      practice count = set.routines[i].practice_count
#	      success count = set.routines[i].success_count
#	      set practice count at last practice = set.routines[i].last_routines_practice_count
#	      last attempt successful? = set.routines[i].last_success_value
#	      last time practiced  = set.routines[i].last_date_practiced
#       score = set.routines[i].score
#-------------------------------------------------------------------
####Todo how do I handle stuff in series?
####Todo track camera usage?

################TODO*****IN PROCESS*****TODO#################
#TODO test addroutine
#TODO make sure exits save properly
#TODO can widget buttons change color or something when clicked?   Also, activate input boxes when button clicked (add routine, add set)
#TODO clean up variable scope in widgets
#TODO reorder method definitions
#Keith's suggestions
# split trainer between object management and training
#	consider getting rapid gui development with qt ruby by pragmatic press
#	may be available fromdemonoid
#	test driven development
#

#add note: git test

require_relative 'marshaller'
require_relative 'addset'
require_relative 'choosesettopractice'
require_relative 'chooseroutinetopractice'
require_relative 'routinetoedit'
require_relative 'editroutine'
require_relative 'addroutine'
require_relative 'howdidyoudo'
require_relative 'deleteroutine'
require_relative 'settodelete'
require_relative 'messagebox'
require_relative 'os'
require_relative 'objects'
require_relative 'objectmanager'
require_relative 'buttonbox'

def is_numeric?(string)
  true if Float(string) rescue false
end

class Trainer

  include Marshaller
  include Os
  include ObjectManager
####  include widgets

  def main #called at startup
    practice_sets, practice_set_names = get_practice_sets
    choose_set_to_practice(practice_sets, practice_set_names)
    MessageBoxWidget.run_qt("Returned to main at exit")
#      write_practice_sets practice_sets     #TODO PM delete?
  end
                                              #TODO adjust widget screen locations
  def choose_set_to_practice(practice_sets, practice_set_names) #called by main and recursed via new_set, add_a_set
    chosen_set_name, option = ChooseSetToPracticeWidget.run_qt(practice_set_names)
    if option == :add_set then get_new_set(practice_sets, practice_set_names) end
    if option == :delete_set then choose_set_to_delete(practice_sets, practice_set_names) end
    if option == :quit then at_exit(practice_sets) end
    if option == :practice then practice_chosen_set(practice_sets, practice_set_names, chosen_set_name) end
  end

  def get_new_set(practice_sets, practice_set_names) #called by choose_set_to_practice
    new_set_name, status = AddSetWidget.run_qt
    if status == :back then choose_set_to_practice(practice_sets, practice_set_names) end
    if status == :quit then at_exit(practice_sets) end
    if status == :done
      if !valid_name(new_set_name) then get_new_set(practice_sets, practice_set_names) end
      get_first_routine(new_set_name, practice_sets, practice_set_names)
    end
  end

  def get_first_routine(new_set_name, practice_sets, practice_set_names) #called by new_set
    message = "Your set needs at least one routine in it"
    MessageBoxWidget.run_qt(message)
    begin
      status, routine = get_new_routine
      if status == :back then choose_set_to_practice(practice_sets, practice_set_names) end
      if status == :quit then return :quit end
      if status == :done
        new_routines = [routine]
        build_set(new_set_name, new_routines, practice_sets, practice_set_names)
      end
    end while ButtonBoxWidget.run_qt("Would you like to add another routine?")
  end

  def get_new_routine(new_routine_name = "", new_routine_link = "") # called by get_first_routine, add_routine, self, practice_routines
    name, link, status, priority = AddRoutineWidget.run_qt(new_routine_name, new_routine_link)
    if status == :quit or status == :back then return status end #status == done
    if valid_name(name) and valid_link(link)
      routine = build_routine(name, link, priority)
    elsif valid_name(name)
      status, routine = get_new_routine(name)
      if status == :quit or status == :back then return status end
    elsif valid_link(link)
      status, routine = get_new_routine("", link)
      if status == :quit or status == :back then return status end
    else
      status, routine = get_new_routine
    end
    return status, routine
  end

  def choose_set_to_delete(practice_sets, practice_set_names)  #called by choose_set_to_practice
    sets_to_delete, status = SetsToDeleteWidget.run_qt(practice_set_names)
    if status == :quit then at_exit(practice_sets) end
    if (sets_to_delete == nil or status == :back) then choose_set_to_practice(practice_sets, practice_set_names) end
#    confirmed = ConfirmDeleteWidget.run_qt(sets_to_delete) #TODO: use ButtonBox instead?
    if confirm_delete(sets_to_delete) == :no then choose_set_to_practice(practice_sets, practice_set_names) end
    delete_sets(sets_to_delete, practice_sets, practice_set_names)
      choose_set_to_practice(practice_sets, practice_set_names)
  end

  def practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) # called by set_up_practice_routines, self, delete_routines, edit_routine, add_routine
    while routines_in_process != []
      chosen_routine, response = ChooseRoutineToPracticeWidget.run_qt(routines_in_process)
      if response == :quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
      if response == :edit_routine
        routine = RoutineToEditWidget.run_qt(chosen_set.routines)
        edit_routine(routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
      end
      if response == :add_routine
        add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size)
        practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
      end
      if response == :delete_routine
        delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)
        practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
      end
      if response == :back then choose_set_to_practice(practice_sets, practice_set_names) end
      practice_routine(chosen_routine, routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)
    end
    if ButtonBoxWidget.run_qt("That's all the routines. Do you want to practice another set?") == :yes then choose_set_to_practice(practice_sets, practice_set_names) end
    index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets)
  end

  def edit_routine(routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) #called by practice_routines, self
    name, link, priority, practice_count, success_count, last_success_value, status = EditRoutineWidget.run_qt(routine)
    if status == :back then practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
    if status == :quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
    if status == :done
      revised_routine = rebuild_routine(routine, name, link, priority, practice_count, success_count, last_success_value)
      replace_routine(routine, revised_routine, chosen_set, routines_in_process)
      practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
    end
  end

  def delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names) #called by practice_routines
    routines_to_delete, status = DeleteRoutineWidget.run_qt(chosen_set.routines)
    if status == :quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
    if status == :back then practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
    if routines_to_delete == (nil or []) then practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
#    confirmed = ConfirmDeleteWidget.run_qt(routines_to_delete)
    if confirm_delete(routines_to_delete) == :no then delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names) end
    delete_routines(routines_in_process, chosen_set, routines_to_delete, initial_set_size)
  end

  def practice_routine(chosen_routine, routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)  #called by practice_routines
    performance_rating, status = HowDidYouDoWidget.run_qt(chosen_routine)
    if ButtonBoxWidget.run_qt("Congratulations on a perfect performance! Would you like to change the priority for this routine?") == :yes then edit_routine(routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
    if status == :show
      launch_routine_file(chosen_routine)
      practice_routine(chosen_routine, routines_in_process, initial_set_size, chosen_set, practice_sets)
    end
    if status == :quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
    if status == :pass
      initial_set_size -= 1
      routines_in_process.delete(chosen_routine)
    else #status == next
      practice_success?(chosen_routine, performance_rating)
      chosen_routine.index_practice_counts(chosen_set.session_count)
      routines_in_process.delete(chosen_routine)
    end
  end

end


#-------------------------------------------------------------------

trainer = Trainer.new.main



