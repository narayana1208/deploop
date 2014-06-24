# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require 'net/ping'
require "mcollective"

include MCollective::RPC
   
module Marionette
  class MCHandler
    def initialize

    end

    def ifHostUp(host)
      Net::Ping::TCP.new(host).ping?
    end

    def checkIfUp(host)
      mc = rpcclient "rpcutil"
      mc.agent_filter "deploop"
      mc.fact_filter "hostname=#{host}"
      mc.progress = false

      result = mc.inventory
      mc.disconnect 

      result
    end

    def deployEnv(host, env)
      mc = rpcclient "deploop"

      mc.identity_filter host
      mc.progress = false

      mc.puppet_environment(:env => env)

      mc.disconnect 
    end

    def deployFact(host, fact, value)
      mc = rpcclient "deploop"

      mc.identity_filter host
      mc.progress = false

      mc.create_fact(:fact => fact, :value => value)

      mc.disconnect 
    end

    def puppetRunBatch(layer, interval)
      mc = rpcclient "puppet"
      mc.compound_filter "deploop_category=#{layer}"
      mc.progress = false

      nodes = mc.discover
      nodes = mc.discover.sort

      result = mc.runonce(:forcerun => true, :batch_size => interval)
      puts "schedule status: #{result[0][:statusmsg]}"
      printrpcstats
    end

  end # class MCHandler
end


