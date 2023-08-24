require 'service_interface/version'

require 'active_support'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/object/inclusion'

module ServiceInterface
  extend ActiveSupport::Concern

  class Argument
    attr_reader :name, :default_value

    def initialize(name:, required:, default_value: nil)
      @name = name
      @required = required
      @default_value = default_value
    end

    def required?
      @required
    end

    def optional?
      !@required
    end
  end

  class_methods do
    # Instance methods can't access class-level instance variables (because of the one @, they look for an instance variable), so define a getter method for them to use.
    def _arguments
      # Hunt through ancestors for arguments data
      arguments_host = self
      while arguments_host != Object
        args = arguments_host.instance_variable_get(:@_arguments)
        return args if args
        arguments_host = arguments_host.superclass
      end

      raise ArgumentError, "Couldn't find interface arguments specified of #{self.name} or its ancestors"
    end

    # Build a collection of arguments, with their names and default values, and store it in a class-level instance variable.
    def arguments(*arguments)
      optional_arguments_with_default_values = arguments.extract_options!
      required_arguments = arguments

      @_arguments = []

      required_arguments.each do |name|
        @_arguments << Argument.new(name: name, required: true)
      end

      optional_arguments_with_default_values.each do |name, default_value|
        @_arguments << Argument.new(name: name, required: false, default_value: default_value)
      end
    end

    def execute(arguments = {})
      new(arguments).send(:execute)
    end
  end

  # Instance methods.
  included do
    def initialize(arguments = {})
      _raise_error_if_any_undeclared_arguments_specified(arguments)
      _set_arguments(arguments)
      _configure_execute_instance_method
      post_initialize(arguments)
    end

    # Inspired by https://stackoverflow.com/a/30950105
    def post_initialize(arguments = {}); end

    def _raise_error_if_any_undeclared_arguments_specified(arguments)
      undeclared_arguments = arguments.reject do |name, value|
        name.in?(self.class._arguments.map(&:name))
      end

      raise ArgumentError, "Unrecognized arguments specified: #{undeclared_arguments.keys.join(', ')}" if undeclared_arguments.any?
    end

    def _set_arguments(arguments)
      arguments_set = _set_specified_arguments(arguments)
      arguments_set += _set_default_values_for_optional_arguments(arguments_set)
      _raise_error_if_any_required_arguments_not_set(arguments_set)
    end

    def _set_specified_arguments(arguments)
      arguments.map do |name, value|
        instance_variable_set("@#{name}", value)
        name
      end
    end

    # Set the values for optional arguments (which have default values) that were not specified at initialization.
    def _set_default_values_for_optional_arguments(arguments_already_set)
      self.class._arguments.map do |argument|
        next if argument.name.in?(arguments_already_set)
        next unless argument.optional?

        instance_variable_set("@#{argument.name}", argument.default_value)
        argument.name
      end.compact
    end

    def _raise_error_if_any_required_arguments_not_set(arguments_set)
      required_arguments_not_set = self.class._arguments.select(&:required?).reject do |argument|
        argument.name.in?(arguments_set)
      end

      raise ArgumentError, "Required arguments (with no default value) not specified: #{required_arguments_not_set.map(&:name).join(', ')}" if required_arguments_not_set.any?
    end

    # Mark the execute instance method as private (so no one can initialize the service class manually and call the execute instance method themselves, thereby bypassing the interface).
    def _configure_execute_instance_method
      self.class.class_eval do
        private :execute
      end
    end
  end
end
