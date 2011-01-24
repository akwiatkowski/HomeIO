#!/usr/bin/ruby
#encoding: utf-8

# This file is part of HomeIO.
#
#    HomeIO is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    HomeIO is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.


require './lib/supervisor/comm_queue.rb'
require './lib/supervisor/supervisor_commands.rb'


# Standard queue enhanced by HomeIO remote command proccesor

class SupervisorQueue < CommQueue

  private

  # Start processing CommQueueTask
  # After finish, result should be stored into :response key
  # Status changes are done elsewhere
  def process_q_task( q_task )
    q_task.set_in_proccess!

    # running commans
    if q_task.type_proc?
      # run proc
      q_task.command.run_proc( Supervisor.instance )
    else
      q_task.response = process_symbol_command( q_task.command, q_task.params )
    end

    q_task.set_done!
  end

  # Process command when it is send as symbol
  def process_symbol_command( command, params )
    return case command
    when SupervisorCommands::FETCH_WEATHER then Supervisor.instance.components[:WeatherRipper].start
    when SupervisorCommands::FETCH_METAR then Supervisor.instance.components[:MetarLogger].start
      # process IM command
    when SupervisorCommands::IM_COMMAND then Supervisor.instance.components[:ImCommandResolver].process_command( params[:string], params[:from] )
    when SupervisorCommands::PROCESS_METAR_CITY then
      begin
        MetarMassProcessor.instance.process_all_for_city( params[:city] )
        {:status => :ok}
      rescue => e
        log_error( self, e )
        puts e.inspect
        puts e.backtrace
        return {:status => :failed}
      end
    when SupervisorCommands::TEST then {:test => :ok}
      # extracting data remotely
      #when :extract then Supervisor.instance.components[:Extractor].remote_command( command )
      # DEV
    when :list_components then {:components => Supervisor.instance.components.keys, :status => :ok}
    else :wrong_command
    end
  end

end
