require 'chef/knife/scalr_base'

# These two are needed for the '--purge' deletion case
require 'chef/node'
require 'chef/api_client'

class Chef
  class Knife
    class ScalrServerDelete < Knife

      include Knife::ScalrBase

      banner "knife Scalr server delete SERVER_ID [SERVER_ID] (options)"

      option :purge,
        :short => "-P",
        :long => "--purge",
        :boolean => true,
        :default => false,
        :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the Scalr node itself. Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The name of the node and client to delete, if it differs from the server name. Only has meaning when used with the '--purge' option."

      # Extracted from Chef::Knife.delete_object, because it has a
      # confirmation step built in... By specifying the '--purge'
      # flag (and also explicitly confirming the server destruction!)
      # the user is already making their intent known.  It is not
      # necessary to make them confirm two more times.
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