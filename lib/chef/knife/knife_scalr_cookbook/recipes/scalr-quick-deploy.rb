require 'chef/knife/scalr_base'
require 'chef/node'
require 'chef/api_client'

class Chef
  class Knife
    class ScalrAPIBase < Knife

      include Knife::ScalrAPIBase

      banner "knife Scalr api  execute SERVER_ID [SERVER_ID] (options)"


    #ApacheVhostCreate
    #ApacheVhostsList
    #BundleTaskGetStatus
    #DmApplicationDeploy
    #DmApplicationsList
    #DmSourcesList
    #DNSZoneCreate
    #DNSZoneRecordAdd
    #DNSZoneRecordRemove
    #DNSZoneRecordsList
    #DNSZonesList
    #EnvironmentsList
    #EventsList
    #FarmClone
    #FarmGetDetails
    #FarmGetStats
    #FarmLaunch
    #FarmsList
    #FarmTerminate
    #LogsList
    #RolesList
    #ScriptExecute  ====>    https://api.scalr.net/?Action=ServerReboot&Version=2.0.0&InstanceID=dbc3e429-ea17-4503-abae-7862f8c467e1&KeyID=<Your Scalr API Key ID>&TimeStamp=2009-06-19T05%3A13%3A00.000Z&Signature=<URLEncode(Base64Encode(Signature))>
    #ScriptGetDetails
    #ScriptsList
    #ServerImageCreate
    #ServerLaunch
    #ServerReboot
    #ServerTerminate
    #StatisticsGetGraphURL



Chef::Configuration.instance(:must_exist).load do
  

  def _cset(name, *args, &block)
    unless exists?(name)
      set(name, *args, &block)
    end
  end

  # =========================================================================
  # These variables MUST be set in the client capfiles. If they are not set,
  # the deploy will fail with an error.
  # =========================================================================

  _cset(:gateway) { abort "Please specify the instance to use as a gateway. Example: set :gateway, 'foo'" }
  _cset(:gateway_type)  { abort "Please specify the type of instance for your gateway. Example: set :gateway_type, 'ubuntu'" }
  ###
  
   namespace :scalr do 
    desc "Enumerate SCALR hosts" 
    # task :enum, :roles=>[:db],  :only => { :primary => true } do 
    task :enum, :roles=>[:gw] do 
      hosts = Hash.new 
      logger.info "SCALR Hosts:"
      if (gateway_type == 'centos')
        hosts_cmd = 'find /etc/scalr/private.d/hosts | cut -d"/" -f6,7 | grep "/"'
      elsif (gateway_type == 'ubuntu')
        hosts_cmd = 'find /etc/aws/hosts | cut -d"/" -f5,6 | grep "/"'
      else
        abort "You must specify a gateway type"
      end
      run hosts_cmd, :pty => true do |ch, stream, out| 
        next if out.chomp == '' 
        logger.info out.sub(/\//,' ') 
        out.split("\r\n").each do |host| 
          host=host.split("/") 
          (hosts[host[0]] ||= []) << host[1] 
        end 
      end
      if hosts.has_key?('mysql')
        if hosts['mysql'].size > 1 
          hosts['mysql'] = hosts['mysql'] - hosts['mysql-master']
        end
      end
      set :scalr_hosts, hosts
    end 
  end 

  scalr.enum




    
      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The name of the node and client to delete, if it differs from the server name. Only has meaning when used with the '--purge' option."


      def destroy_item(klass, name, type_name)
        begin
          object = klass.load(name)
          object.destroy
          ui.warn("Deleted #{type_name} #{name}")
        rescue Net::HTTPServerException
          ui.warn("Could not find a #{type_name} named #{name} to delete!")
        end
      end

      def run
        @name_args.each do |instance_id|
          begin
            server = connection.servers.get(instance_id)
            msg_pair("Instance ID", server.id.to_s)
            msg_pair("Host ID", server.host_id)
            msg_pair("Name", server.name)
            msg_pair("Flavor", server.flavor.name)
            msg_pair("Image", server.image.name)
            msg_pair("Public IP Address", public_ip(server))
            msg_pair("Private IP Address", private_ip(server))

            puts "\n"
            confirm("Do you really want to delete this server")

            server.destroy

            ui.warn("Deleted server #{server.id}")

            if config[:purge]
              if version_one?
                thing_to_delete = config[:chef_node_name] || instance_id
                destroy_item(Chef::Node, thing_to_delete, "node")
                destroy_item(Chef::ApiClient, thing_to_delete, "client")
              else
                #v2 nodes may be named automatically
                thing_to_delete = config[:chef_node_name] || server.name
                destroy_item(Chef::Node, thing_to_delete, "node")
                destroy_item(Chef::ApiClient, thing_to_delete, "client")
              end
            else
              ui.warn("Corresponding node and client for the #{instance_id} server were not deleted and remain registered with the Chef Server")
            end

          rescue NoMethodError
            ui.error("Could not locate server '#{instance_id}'.")
          end
        end
      end
    end
  end
end