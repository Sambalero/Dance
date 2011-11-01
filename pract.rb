#!/usr/bin/env ruby
#
################TODO*****IN PROCESS*****TODO#################
#TODO make sure exits save properly
#TODO can widget buttons change color or something when clicked?
#TODO clean up variable scope in widgets

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
require_relative 'getfile'

def is_numeric?(string)
  true if Float(string) rescue false
end

class Trainer

  include Marshaller
  include Os
  include ObjectManager
  include GetFile

  def main #called at startup

#     file_name  = Qt::FileDialog.new
#    file_name = GetFileWidget.run_qt()
#    puts "file name is: #{file_name}"

#file_name = get_file
#puts "file name is #{file_name}"


    practice_sets, practice_set_names = get_practice_sets
    choose_set_to_practice(practice_sets, practice_set_names)
    MessageBoxWidget.run_qt("Returned to main at exit")



#      write_practice_sets practice_sets
  end

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
    if status == :getFile
      new_routine_link = get_file
      if valid_name(name) then new_routine_name = name end
      name, link, status, priority = AddRoutineWidget.run_qt(new_routine_name, new_routine_link)
    end
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
    if status == :getFile
      routine.link = get_file
      if valid_name(name) then routine.name = name
      name, link, priority, practice_count, success_count, last_success_value, status = EditRoutineWidget.run_qt(routine)
      end
    end
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
    if confirm_delete(routines_to_delete) == :no then delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names) end
    delete_routines(routines_in_process, chosen_set, routines_to_delete, initial_set_size)
  end

  def practice_routine(chosen_routine, routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)  #called by practice_routines
    performance_rating, status = HowDidYouDoWidget.run_qt(chosen_routine)
    if practice_success?(chosen_routine, performance_rating)
      if ButtonBoxWidget.run_qt("Congratulations on a perfect performance! Would you like to change the priority for this routine?") == :yes then edit_routine(routine, chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
    end
    if status == :show
      launch_routine_file(chosen_routine)
      practice_routine(chosen_routine, routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)
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



