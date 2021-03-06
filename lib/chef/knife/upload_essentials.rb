require 'chef_fs/knife'
require 'chef_fs/command_line'

class Chef
  class Knife
    remove_const(:Upload) if const_defined?(:Upload) && Upload.name == 'Chef::Knife::Upload' # override Chef's version
    class Upload < ::ChefFS::Knife
      ChefFS = ::ChefFS
      banner "knife upload PATTERNS"

      common_options

      option :recurse,
        :long => '--[no-]recurse',
        :boolean => true,
        :default => true,
        :description => "List directories recursively."

      option :purge,
        :long => '--[no-]purge',
        :boolean => true,
        :default => false,
        :description => "Delete matching local files and directories that do not exist remotely."

      option :force,
        :long => '--[no-]force',
        :boolean => true,
        :default => false,
        :description => "Force upload of files even if they match (quicker and harmless, but doesn't print out what it changed)"

      option :dry_run,
        :long => '--dry-run',
        :short => '-n',
        :boolean => true,
        :default => false,
        :description => "Don't take action, only print what would happen"

      def run
        if name_args.length == 0
          show_usage
          ui.fatal("Must specify at least one argument.  If you want to upload everything in this directory, type \"knife upload .\"")
          exit 1
        end

        error = false
        pattern_args.each do |pattern|
          error ||= ChefFS::FileSystem.copy_to(pattern, local_fs, chef_fs, config[:recurse] ? nil : 1, config, ui, proc { |entry| format_path(entry) })
        end
        if error
          exit 1
        end
      end
    end
  end
end

