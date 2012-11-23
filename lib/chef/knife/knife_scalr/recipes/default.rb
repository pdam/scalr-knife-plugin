#
# Cookbook Name:: knife_install
# Recipe:: default
#
# 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# Get the :intall_recipes list and save it to a permanent attribute.  This is in a ruby_block so that it runs
# during execute phase, that way :intall_recipes is complete since it is populated during compile phase.  Once
# this has been placed in an attribute, the end-of-run node.save will save it so that knife audit can get
# the node's full runlist from the chef server.

ruby_block "get_installed_recipes" do
  block do
    runlist = node.run_state[:installed_recipes]
    node.set["knife_scalr"]["installed_recipes"] = runlist
  end
  action :create
end
