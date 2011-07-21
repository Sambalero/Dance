require 'csv'

FILENAME = 'practice1.csv'
ROUTINELENGTH = 8
SETDATALENGTH = 3


module Marshaller


  def marshal #called by trainer.main
    practice_sets = []
    practice_set_names = []
    array = load_raw_data
    delete_header(array)
    num_sets = array.shift

    num_sets.to_i.times do
      set_length = calculate_set_length(array)
      set_array = array.slice!(0...set_length)
      practice_set = marshal_set(set_array)
      practice_sets << practice_set
      practice_set_names << practice_set.name
    end

    return practice_sets, practice_set_names
  end

  def load_raw_data #called by marshal
    raw_data_array = CSV.read FILENAME
    raw_data_array.flatten!
    raw_data_array.compact!
    raw_data_array = raw_data_array.map { |b| is_numeric?(b) ? b.to_f : b.chomp }
  end

  def calculate_set_length(array) #called by marshal
    num_routines = array[2*SETDATALENGTH - 1] #last item in set data with headers, indexed at 0
    set_length = 2*SETDATALENGTH + (1+num_routines)*ROUTINELENGTH #set data with headers, routine headers, routines
  end

  def marshal_set(array) #called by marshal
    name, practice_session_count, num_routines = get_set_data array.slice!(0...2*SETDATALENGTH)
    delete_routine_header_row(array)
    routines = marshal_routines(array, num_routines)
    practice_set = PracticeSet.new(name, practice_session_count, routines)
  end

  def delete_routine_header_row(array) #called by marshal_set
    ROUTINELENGTH.times do
      array.delete_at(0)
    end
  end

  def delete_header(array) #called by marshal and get_set_data
    array.delete_at(0)
  end

  def get_set_data(array) #called by marshal set could build button set lable set with this
    delete_header(array)
    name = array.shift
    delete_header(array)
    practice_session_count = array.shift
    delete_header(array)
    num_routines = array.shift
    return name, practice_session_count, num_routines
  end

  def marshal_routines(array, num_routines) #called by marshal_set
    routines = []
    (0...num_routines).each do #marshal routines
      routine = marshal_routine array.slice!(0...ROUTINELENGTH)
      routines << routine
    end
    return routines
  end

  def marshal_routine(array) #called by marshal_routines
        routine = Routine.new({
          :name => array.shift,
          :link => array.shift,
          :priority => array.shift,
          :practice_count => array.shift,
          :success_count => array.shift,
          :last_routines_practice_count => array.shift,
          :last_success_value => array.shift,
          :score => array.shift })
  end

  def top_row(name, value) #called by unmarshal
    row = []
    row[0] = name
    row[1] = value
    row[2...ROUTINELENGTH] = nil
    return row
  end

  def header_row #called by unmarshal
    row = ["Routine Name","Location","Priority","Practice Count","Success Count","Set Practice Count at Last Practice","Last Attempt Successful?", "Score"]
  end

  def write_set_data(array, set)#called by unmarshal
      array.push(top_row "Name", set.name)
      array.push(top_row "Number of Practice Sessions", set.num_practices)
      array.push(top_row "Number of Routines", set.routines.length)
      array.push(header_row)
  end

  def write_routine(row, routine)#called by unmarshal
        row.push(routine.name)
        row.push(routine.link)
        row.push(routine.priority)
        row.push(routine.practice_count)
        row.push(routine.success_count)
        row.push(routine.last_routines_practice_count)
        row.push(routine.last_success_value)
        row.push(routine.score)
        return row
  end

  def unmarshal(sets) #called by write_practice_sets
    array = []
    array[0] = top_row "Number of Sets", sets.length
    sets.each do |set|
      write_set_data(array, set)
      set.routines.each do |routine|
        row = []
        write_routine(row, routine)
        array.push(row)
      end
    end
    return array
  end

	def write_practice_sets(sets) #called by trainer.main
    array = unmarshal sets
    CSV.open FILENAME, "w" do |csv|
      (0...array.length).each do |i|
        csv << array[i]
      end
    end
  end
end

