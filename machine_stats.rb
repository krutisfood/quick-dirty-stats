#!/usr/bin/env ruby

require 'logger'
require 'influxdb'

$logger = Logger.new(STDOUT)

module Metrics
  class Machine

    def initialize
    end
  
    def load_data
      output = %x(free)
      @memory = Hash.new
      @memory[:total] = output.split(" ")[7].to_f
      @memory[:used]  = output.split(" ")[8].to_f
      @memory[:free]  = output.split(" ")[9].to_f
    end
  
    def print
      @memory.each do |desc,value|
        $logger.debug "#{desc}: #{value}"
      end
    end

    def publish_to(host)
      database = 'nubuntu'
      username = 'root'
      password = 'root'
      influxdb = InfluxDB::Client.new database, :host => host, :username => username, :password => password
      name = 'machine' 
      influxdb.write_point(name, @memory)
      $logger.debug "Done"
    end
  end
end


machine = Metrics::Machine.new 
machine.load_data
machine.print
machine.publish_to 'localhost'
