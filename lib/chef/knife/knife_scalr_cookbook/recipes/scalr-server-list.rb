require 'chef/knife/scalr_base'

class Chef
  class Knife
    class ScalrServerList < Knife

      include Knife::scalrBase

      banner "knife scalr server list (options)"

      def run
        $stdout.sync = true

        server_list = [
          ui.color('Instance ID', :bold),
          ui.color('Name', :bold),
          ui.color('Public IP', :bold),
          ui.color('Private IP', :bold),
          ui.color('Flavor', :bold),
          ui.color('Image', :bold),
          ui.color('State', :bold)
        ]
        connection.servers.all.each do |server|
          server = connection.servers.get(server.id)
          server_list << server.id.to_s
          server_list << server.name
          server_list << public_ip(server)
          server_list << private_ip(server)
          server_list << (server.flavor_id == nil ? "" : server.flavor_id.to_s)
          server_list << (server.image_id == nil ? "" : server.image_id.to_s)
          server_list << begin
            case server.state.downcase
            when 'deleted','suspended'
              ui.color(server.state.downcase, :red)
            when 'build','unknown'
              ui.color(server.state.downcase, :yellow)
            else
              ui.color(server.state.downcase, :green)
            end
          end
        end
        puts ui.list(server_list, :uneven_columns_across, 7)
      end
    end
  end
end