module LiftContainer

  LIMIT_MAN = 5

  TOP_FLOOR = 12


  module LiftWorkflow

    def open_door #открытие дверей лифта на этаже
      puts "открыты двери на этаже #{@current_floor}"
      @man_inside.select{ |man| man[:to]==@current_floor }.each { |man| outgoing(@man_inside.delete(man)) }
      @direction = 0 if @man_inside.empty?
      @man_outside.select{ |man| man[:from]==@current_floor }.each do |man|
        if @man_inside.count < LIMIT_MAN
          if @direction==0 || @direction==get_direction(man[:from], man[:to])
            coming(@man_outside.delete(man))
            if @direction==0
              @direction = get_direction(man[:from], man[:to])
              puts "новый пассажир определил направление движения #{direction_name}"
            end
          else
            puts "Не удалось взять пассажира #{man[:id]} с этажа #{man[:from]}, т.к. он ожидает движения в противоположном направлении"
          end
        else
          puts "Не удалось взять пассажира #{man[:id]} с этажа #{man[:from]}, т.к. лифт переполнен"
        end
      end
    end

    def try_move #логика движения лифта
      last_state =  @direction

      if @direction==1
        if @man_inside.empty?
          #next_stop = @man_outside.map { |man| man[:from] }.select { |x| x > @current_floor }.min
          next_stop = @man_outside.first[:from] unless @man_outside.empty?
        else
          next_stop = @man_inside.map { |man| man[:to] }.select { |x| x > @current_floor }.min
        end
      elsif @direction==-1
        next_stop = (@man_inside.map { |man| man[:to] } | @man_outside.map { |man| man[:from] } ).select { |x| x < @current_floor }.max
      else
        if @man_outside.empty?
          next_stop = nil
        else
          if @man_outside.first[:from] == @current_floor
            open_door
            next_stop = @man_inside.first[:to]
          else
            next_stop = @man_outside.first[:from]
          end
        end
      end

      unless next_stop.nil?
        @direction = get_direction(@current_floor, next_stop)
        @current_floor += @direction
        puts "лифт проследовал до этажа #{@current_floor}"
        if @man_inside.any? { |man| man[:to] == @current_floor } ||
            @direction < 1 && @man_outside.any? { |man| man[:from] == @current_floor} ||
            @man_inside.empty? && @direction == 1 && @man_outside.first[:from] == @current_floor
          open_door
        end
      else
        @direction = 0
        puts "лифт стоит на месте - нет вызовов или пассажиров внутри" if last_state != @direction && @man_outside.empty?
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

    def coming(man) #обработка посадки в лифт
      @man_inside << man
      puts "пассажир #{man[:id]} вошел на этаже #{man[:from]} (предполагается поездка на этаж #{man[:to]})"
    end

    def outgoing(man) #обработка высадки из лифта
      puts "пассажир #{man[:id]} вышел на этаже #@current_floor"
    end

  end


end