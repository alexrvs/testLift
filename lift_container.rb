module LiftContainer

  LIMIT_MAN = 5

  TOP_FLOOR = 12


  module LiftWorkflow

    def open_door
      puts "открыты двери на этаже #{@current_floor}"
      @man_inside.select{ |man| man[:to]==@current_floor }.each { |man| outgoing(@man_inside.delete(man))}
      @direction = 0 if @man_inside.empty?
      @man_outside.select{ |man| man[:from]==@current_floor}.each do |man|
        if @man_inside.count < LIMIT_MAN
          if @direction == 0 || @direction == get_direction(man[:from],  man[:to])
            coming(@man_outside.delete(man))
            if @direction == 0
              @direction = get_direction(man[:from], man[:to])
              puts "вошедший пассажир определил направление движения #{direction_name} на этаж #{man[:to]}"
            end
          else
            puts "Не удалось взять пассажира #{man[:id]} с этажа #{man[:from]}, т.к. он ожидает движения в противоположном направлении"
          end
        else
          puts "Пассажира #{man[:id]}  с этажа #{man[:from]} не влез, т.к. лифт забит"
        end
      end
    end


    def moveLift

      last_state_lift = @direction

      if @direction == 1
        if @man_inside.empty?
          next_stop_lift = @man_outside.first[:from] unless @man_outside.empty?
        else
          next_stop_lift = @man_inside.map{|man| man[:to]}.select{|x| x > @current_floor}.min
        end
        elsif @direction == -1
          next_stop_lift = (@man_inside.map {|man| man[:to]} | @man_outside.map {|man| man[:from]}).select { |x| x< @current_floor}.max
      else
        if @man_outside.empty?
          next_stop_lift = nil
        else
          if @man_outside.first[:from] == @current_floor
            open_door
            next_stop_lift = @man_inside.first[:to]
          else
            next_stop_lift = @man_outside.first[:from]
          end
        end
      end

      unless next_stop_lift.nil?
        @direction = get_direction(@current_floor, next_stop_lift)
        @current_floor += @direction
        puts "лифт поехал на этаж #{@current_floor}"
        if @man_inside.any? {|man| man[:to] == @current_floor} ||
            @direction < 1 && @man_outside.any? {|man| man[:from] == @current_floor} ||
            @man_inside.empty? && @direction == 1 && @man_outside.first[:from] == @current_floor
          open_door
        end
      else
        @direction = 0
        puts "лифт в ожидании поработать)))" if last_state_lift != @direction && @man_outside.empty?
      end
    end
  end

  module Man
    @@counter = 0

    def request(at_floor, destination_floor) #обработка вызова лифта
      if at_floor<1 || at_floor>TOP_FLOOR
        puts "пассажир не может находиться на этаже #{at_floor}"
      elsif destination_floor<1 || destination_floor>TOP_FLOOR
        puts "пассажир не может запросить этаж #{destination_floor}"
      elsif at_floor==destination_floor
        puts "бессмысленно заказывать этаж, на котором уже находишься"
      else
        @man_outside << {:from => at_floor, :to => destination_floor, :id => @@counter += 1}
        puts "зарегистрирован вызов на этаже #{at_floor} (предполагается поездка на этаж #{destination_floor})"
      end
    end

    def coming(man)
      @man_inside << man
      puts "Пассажир #{man[:id]} зашел на #{man[:from]} этаже, пытаеться добраться на #{man[:to]}"
    end

    def outgoing(man)
      puts "Пассажир #{man[:id]} вышел на этаже #@current_floor"
    end

  end


end