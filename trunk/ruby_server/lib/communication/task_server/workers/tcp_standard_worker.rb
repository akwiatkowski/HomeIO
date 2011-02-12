require 'singleton'
require "lib/communication/db/extractor_active_record"
require "lib/communication/task_server/tcp_task"
require "lib/communication/db/extractor_active_record"

# Standard, universal worker used for commands sent on main port

class TcpStandardWorker
  include Singleton

  def initialize
    @commands = commands
  end

  # Process command/TCP task
  def process(tcp_task)
    puts tcp_task.inspect

    # process only TcpTask
    return :wrong_object_type unless tcp_task.kind_of? TcpTask

    # select command
    command = @commands.select { |c| c[:command].select { |d| d == tcp_task.command }.size > 0 }
    return :wrong_command if command.size == 0

    command = command.first
    begin
      return command[:proc].call
    rescue => e
      log_error(self, e, "command: #{tcp_task.inspect}")
      show_error(e)
      return {:error => e.to_s}
    end

  end

  private

  # Commands definition
  def commands
    ExtractorActiveRecord
    [
        {
            :command => ['help', '?'],
            :desc => 'this help :]',
            :proc => Proc.new { |params| commands_help },
            #:restricted => false
        },
            {
                :command => ['c'],
                :desc => 'list of all cities',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.get_cities },
                #:restricted => false
            },
            {
                :command => ['ci'],
                :desc => 'city logged data basic statistics',
                :usage_desc => '<id, metar code, name or name fragment>',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.city_basic_info(params[1]) },
                #:restricted => false
            },
            {
                :command => ['cix'],
                :desc => 'city logged data advanced statistics',
                :usage_desc => '<id, metar code, name or name fragment>',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.city_adv_info(params[1]) },
                #:restricted => false
            },
            {
                :command => ['wmc'],
                :desc => 'last metar data for city',
                :usage_desc => '<id, metar code, name or name fragment>',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.get_last_metar(params[1]) },
                #:restricted => false
            },
            {
                :command => ['wms'],
                :desc => 'metar summary of all cities',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.summary_metar_list },
                #:restricted => false
            },
            {
                :command => ['wma'],
                :desc => 'get <count> last metars for city',
                :usage_desc => '<id, metar code, name or name fragment> <count>',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.get_array_of_last_metar(params[1], params[2]) },
                #:restricted => false
            },
            {
                :command => ['wra'],
                :desc => 'get <count> last weather (non-metar) data for city',
                :usage_desc => '<id, metar code, name or name fragment> <count>',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.get_array_of_last_weather(params[1], params[2]) },
                #:restricted => false
            },
            {
                :command => ['wmsr'],
                :desc => 'search for metar data for city at specified time',
                :usage_desc => '<id, metar code, name or name fragment> <time ex. 2010-01-01 12:00>',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.search_metar(params) },
                #:restricted => false
            },
            {
                :command => ['wrsr'],
                :desc => 'search for weather (non-metar) data for city at specified time',
                :usage_desc => '<id, metar code, name or name fragment> <time ex. 2010-01-01 12:00>',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.search_weather(params) },
                #:restricted => false
            },
            {
                :command => ['wsr'],
                :desc => 'search for weather (metar or non-metar) data for city at specified time',
                :usage_desc => '<id, metar code, name or name fragment> <time ex. 2010-01-01 12:00>',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.search_metar_or_weather(params) },
                #:restricted => false
            },
            {
                :command => ['cps'],
                :desc => 'calculate city periodical stats (metar or non-metar) at specified time interval',
                :usage_desc => '<id, metar code, name or name fragment> <time ex. 2010-01-01 12:00> <time ex. 2010-01-02 12:00>',
                :proc => Proc.new { |params| ExtractorActiveRecord.instance.city_calculate_periodical_stats(params) },
                #:restricted => false
            },
            {
                :command => ['queue'],
                :desc => 'get queue',
                :usage_desc => '',
                :proc => Proc.new { |params| get_queue },
                #:restricted => false
            },
    ]
  end

end