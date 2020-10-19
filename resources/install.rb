#
# Cookbook:: pyload
# Resource:: install
#
# Copyright:: 2020, Dominik Jessich
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

include PyloadCookbook::Helpers

property :instance_name, String, name_property: true
property :version, [String, Integer], default: lazy { default_pyload_version }
property :install_method, String, equal_to: %w(pip tarball_pip), default: 'tarball_pip'
property :install_dir, String, default: lazy { default_pyload_install_dir }
property :data_dir, String, default: lazy { default_pyload_data_dir }
property :log_dir, String, default: lazy { default_pyload_log_dir }
property :download_dir, String, default: lazy { default_pyload_download_dir }
property :tmp_dir, String, default: lazy { default_pyload_tmp_dir }
property :user, String, default: lazy { default_pyload_user }
property :group, String, default: lazy { default_pyload_group }
property :tarball_path, String, default: lazy { default_pyload_tarball_path(version) }, desired_state: false
property :tarball_url, String, default: lazy { default_pyload_tarball_url(version) }, desired_state: false
property :tarball_checksum, String, regex: /^[a-zA-Z0-9]{64}$/, default: lazy { default_pyload_tarball_checksum(version) }, desired_state: false
property :create_user, [true, false], default: true, desired_state: false
property :create_group, [true, false], default: true, desired_state: false
property :create_download_dir, [true, false], default: true, desired_state: false
property :create_symlink, [true, false], default: true, desired_state: false

action :install do
  case new_resource.install_method
  when 'tarball_pip'
    raise "Install method #{new_resource.install_method} is only supported for version < 0.5.0." if pyload_next?(new_resource.version)

    pyload_install_tarball_pip new_resource.version do
      copy_properties_from(new_resource, :install_dir, :data_dir, :log_dir, :download_dir, :user, :group, :tarball_path, :tarball_url, :tarball_checksum, :create_user, :create_group, :create_download_dir, :create_symlink, :sensitive)
    end
  when 'pip'
    raise "Install method #{new_resource.install_method} is only supported for version >= 0.5.0." unless pyload_next?(new_resource.version)

    pyload_install_pip new_resource.version do
      copy_properties_from(new_resource, :install_dir, :data_dir, :log_dir, :download_dir, :tmp_dir, :user, :group, :create_user, :create_group, :create_download_dir, :create_symlink, :sensitive)
    end
  else
    raise "Invalid install method #{new_resource.install_method} specified."
  end
end
