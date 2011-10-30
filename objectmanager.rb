module ObjectManager

  def get_practice_sets #called trainer.main
#  test = TestWidget.run_qt("word")
#  puts "test = #{test}"
    practice_sets = []
    if File.exist? FILENAME
      practice_sets, practice_set_names = marshal
      return practice_sets, practice_set_names
      write_practice_sets practice_sets
    else
      MessageBoxWidget.run_qt("Your set needs at least one routine in it")
    end
  end

  def at_exit(practice_sets = [])  # called in many places
    puts "Goodbye."
    write_practice_sets practice_sets
    exit
  end

  def build_routine(new_routine_name, new_routine_link, priority = 1) #called by trainer.get_new_routine
    routine = Routine.new({
      :name => new_routine_name,
      :link => new_routine_link,
      :priority => priority,
      :practice_count => 0,
      :success_count => 0,
      :last_routines_practice_count => 0,
      :last_success_value => 0.1,
      :last_date_practiced => Time.now,
      :score => 0 })
  end

  def build_set(new_set_name, new_routines, practice_sets, practice_set_names) #called by trainer.get_first_routine
    new_set = PracticeSet.new(new_set_name, 0, new_routines)
    practice_sets.push(new_set)
    practice_set_names.push(new_set_name)
    write_practice_sets(practice_sets)
    practice_sets, practice_set_names = marshal
    choose_set_to_practice(practice_sets, practice_set_names)
  end

  def valid_name(name) #called by trainer.new_set, trainer.get_new_routine
    if (name != nil and !name.empty?) then return true end
    MessageBoxWidget.run_qt("Please enter a name.")
    return false
  end

  def valid_link(link) #called by trainer.get_new_routine
    if (link != nil and !link.empty?) then return true end
    MessageBoxWidget.run_qt("Please enter something in the link field.")
    return false
  end

  def index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) #called by add_routine, triner.practice_routines, trainer.edit_routine, trainer.delete_routine, trainer.practice_routine
    if routines_in_process.length < initial_set_size then chosen_set.session_count +=1 end
    at_exit(practice_sets)
  end

  def add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size) #called by trainer.practice_routines
    status, new_routine = get_new_routine
    if status == :back then practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
    if status == :quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
    if status == :done
      chosen_set.routines.push(new_routine)
      write_practice_sets practice_sets
      practice_sets, practice_set_names = marshal
      chosen_set = get_new_chosen_set(practice_sets, chosen_set)
      routines_in_process = re_create_routines_in_process(chosen_set, routines_in_process, new_routine)
      initial_set_size += 1
      practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
    end
  end

  def re_create_routines_in_process(chosen_set, routines_in_process, new_routine) #called by trainer.add_routine
    new_routines_in_process = chosen_set.routines.clone
    old_routines_in_process_names = []
    routines_in_process.each do |routine|
       old_routines_in_process_names.push(routine.name)
    end
    old_routines_in_process_names.push(new_routine.name)
    new_routines_in_process.each do |routine|
      new_routines_in_process.delete routine if not old_routines_in_process_names.include? routine.name
    end
    return new_routines_in_process
  end

  def get_new_chosen_set(practice_sets, chosen_set) #called by add_routine
    new_chosen_set = ""
    practice_sets.each do |set|
      new_chosen_set = set if set.name == chosen_set.name
    end
    return new_chosen_set
  end

  def delete_sets(sets_to_delete, practice_sets, practice_set_names) #called by trainer.choose_set_to_delete
    sets_to_delete.each do |set_to_delete|
      practice_sets.each do |set|
        practice_sets.delete(set) if set.name == set_to_delete
      end
      practice_set_names.each do |name|
        practice_set_names.delete(name) if name == set_to_delete
      end
    end
  end

  def confirm_delete(deletees)
    message = "This will delete: \n"
    deletees.each do |deletee|
      if deletee.class == Routine
        message = "#{message}\n  #{deletee.name}"
      else
        message = "#{message}\n  #{deletee}"
      end
    end
    message = "#{message}\n\nContinue?"
    ButtonBoxWidget.run_qt(message)
  end

  def practice_chosen_set(practice_sets, practice_set_names, chosen_set_name)  #called by choose_set_to_practice
    chosen_set_index = practice_set_names.index(chosen_set_name)
    chosen_set = practice_sets[chosen_set_index]
    chosen_set.sort_routines_by_score
    set_up_practice_routines(chosen_set, practice_sets, practice_set_names)
  end

  def set_up_practice_routines(chosen_set, practice_sets, practice_set_names)  # called by practice_chosen_set  #recombine with caller?
    initial_set_size = chosen_set.routines.length
    routines_in_process = chosen_set.routines.clone
    practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
  end

  def rebuild_routine(routine, name, link, priority, practice_count, success_count, last_success_value)
    revised_routine = build_routine(name, link, priority)
    revised_routine.practice_count = practice_count
    revised_routine.success_count = success_count
    if last_success_value   #should be change_last_success_value
     revised_routine.last_success_value = (routine.last_success_value ==  0.1 ? 1 : 0.1)
    end
    revised_routine.last_routines_practice_count = routine.last_routines_practice_count
    revised_routine.last_date_practiced = routine.last_date_practiced
    revised_routine.score = routine.score
    return revised_routine
  end

  def replace_routine(routine, revised_routine, chosen_set, routines_in_process)
    routine_index = chosen_set.routines.index(routine)   #?
    rip_routine_index = routines_in_process.index(routine)
    chosen_set.routines[routine_index] = revised_routine
    if rip_routine_index != nil
      routines_in_process[rip_routine_index] = revised_routine
    end
  end

  def delete_routines(routines_in_process, chosen_set, routines_to_delete, initial_set_size)   # called by trainer.delete_routine
    routines_to_delete.each do |routine_to_delete|

    chosen_set.routines.each do |routine|
      chosen_set.routines.delete(routine) if routine_to_delete.name == routine.name
    end

    routines_in_process.each do |routine|
      routines_in_process.delete(routine) if routine_to_delete.name == routine.name
    end
    initial_set_size -= 1
    end
  end

  def practice_success?(chosen_routine, performance_rating) #called by trainer.practice_routines
      if performance_rating == 5 or (performance_rating == 4 and chosen_routine.priority < 4)
        chosen_routine.index_success_counts
      else
        chosen_routine.last_success_value = 0.1
      end
  end

end
