#MIT LICENSE
#
#Copyright (c) 2012 SUSE Linux Products GmbH
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

require 'yaml'
require 'erb'
require 'deep_merge'

require "#{File.dirname(__FILE__)}/utils"

module Common

  class Options

    def initialize(cfg_file = 'config/options.yml', local_cfg_file = 'config/options-local.yml', load_env = nil)
      Common::Utils::suppress_warnings do
        @load_env = load_env
        @cfg_file = cfg_file
        @local_cfg_file = local_cfg_file
        @tmp_cmdl_file = 'tmp/options-cmd-line.yml'
        @persistent_local_cfg_file = '/etc/options.yml'
        if defined? Rails
          @cfg_file = Rails.root.to_s + '/' + @cfg_file
          @local_cfg_file = Rails.root.to_s + '/' + @local_cfg_file
          @persistent_local_cfg_file = "/etc/config/#{Rails.root.to_s.split("/")[-1]}/options.yml"
        end
      end
      @options = {}
      reload!
    end

    def reload!
      cmd_line_args = {}

      if File.exists? @tmp_cmdl_file
        cmd_line_args = load_file(@tmp_cmdl_file)

        # Don't remove tmp_cmdl_file if the keep_tmp_cmdl_file flag is set.
        if defined? KEEP_TMP_CMDL_FILE and KEEP_TMP_CMDL_FILE
          Object.instance_eval { remove_const :KEEP_TMP_CMDL_FILE }
        else
          FileUtils.rm @tmp_cmdl_file
        end
      end

      if defined? Rails
        cmd_line_args['environment'] = Rails.env.to_s
      else
        cmd_line_args['environment'] = @load_env.to_s
      end

      if cmd_line_args['environment'] == 'test' and cmd_line_args['verbose'].nil?
        cmd_line_args['verbose'] = 'silent'
      end

      if cmd_line_args['environment'].nil?
        defaults = read_options({:environment => 'default',
                                 :config_file => cmd_line_args['config-file'],
                                 :verbose => 'silent'})
        cmd_line_args['environment'] = defaults['environment'] || 'development'
      end

      @options = read_options({:environment => cmd_line_args['environment'],
                               :config_file => cmd_line_args['config-file'],
                               :verbose => cmd_line_args['verbose']}, cmd_line_args)
    end

    # Read the options from the config file.
    # cfg_file is the default config file. If local_cfg_file exists, the options
    # specified there overrides those in cfg_file. If :config_file is specified,
    # it is used in place of local_cfg_file.
    # If :environment is specified, the options in the corresponding environment
    # is loaded and merged with those in 'default'.
    def read_options args={}, update_options={}
      args = {:environment => nil,
              :config_file => nil,
              :verbose => 'silent'
      }.update(args)

      options = {}

      if File.exists? @cfg_file
        vputs "Loading '#{@cfg_file}'", args[:verbose]
        options = load_file @cfg_file
      end

      if args[:config_file]
        if !File.exists? args[:config_file]
          vputs "ERROR: Config file '#{args[:config_file]}' not found!", args[:verbose]
          exit
        end
        vputs "Loading '#{args[:config_file]}'", args[:verbose]
        update_options(args[:config_file], options)
      elsif @persistent_local_cfg_file && File.exists?(@persistent_local_cfg_file)
        vputs "Loading '#{@persistent_local_cfg_file}'", args[:verbose]
        update_options(@persistent_local_cfg_file, options)
      elsif @local_cfg_file && File.exists?(@local_cfg_file)
        vputs "Loading '#{@local_cfg_file}'", args[:verbose]
        update_options(@local_cfg_file, options)
      end

      if args[:environment]
        vputs "Using environment '#{args[:environment]}'", args[:verbose]
        options = (options['default']||{}).deep_merge!(options[args[:environment]]||{})
      end

      options.update(update_options)
      options['environment'] = 'development' if options['environment'].nil?
      options['verbose'] = false if options['verbose'].nil?

      if args[:verbose] == true
        len = options.keys.map { |k| k.size }.sort.last
        vputs "Loaded options:", args[:verbose]
        options.each { |k, v| puts "   #{k.ljust(len)} => #{v}" }
      end

      options
    end


    private

    def load_file(filename)
      YAML.load(ERB.new(File.read(filename)).result binding)
    end

    def vputs msg, verbose
      return if verbose == 'silent' || verbose.nil?
      puts "** P#{Process.pid} #{msg}"
    end

    # Allows retrieval of option value (i.e. options.option_name) that matches
    # the key name in the config file.
    def method_missing method_name, *arg
      if method_name.to_s =~ /(.*)=$/
        key = $1
        if @options.has_key? key
          @options[key] = arg[0]
          return @options[key]
        end
      else
        key = method_name.to_s
        if @options.has_key? key
          return @options[key]
        end
      end
      raise NoMethodError.new("undefined method `#{key}' for Options:Class", "unknown_key")
    end

    # Merge options with content of <file>.
    def update_options file, options
      options.deep_merge!(load_file(file))
    end

  end
end
