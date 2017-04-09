class LiftApp

  class << self

    def run
      require_relative "lift_container"
      require_relative "lift"
      require_relative "man"

      puts "Нажмите <Enter> для вызова лифта"
      l = Lift.new
      loop do
        begin
          STDIN.read_nonblock(1)
          puts "Вы вызвали лифт!"
          puts "Укажите с какого этажа будете ехать:"
          from  = gets.chomp
          puts "Укажите на какой этаж будете ехать:"
          to = gets.chomp
          unless from.empty? &&  to.empty?
            l.request(from.to_i, to.to_i)
          end

        rescue SystemCallError
        end
        l.moveLift
        sleep(2)
      end
    end
  end
end

