class Lift


  include LiftContainer::LiftWorkflow

  include LiftContainer::Man


  attr_reader :man_inside, :man_outside
  attr_writer :man_inside, :man_outside

  def initialize
    @man_inside = []
    @man_outside = []
    @current_floor = 1
    @direction_lift = 0
  end


  def get_direction(from, to)
     (to - from) <=> 0
  end

  def direction_name
    case @direction_lift
      when -1 then "вниз"
      when 0 then "стоим на месте"
      when 1 then "вверх"

    end

  end

end