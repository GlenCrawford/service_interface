# ServiceInterface

A Ruby module that can be included into service classes that provides a strict, boilerplate interface, taking care of defining a class-level `execute` method, instantiating the service and invoking the instance-level `execute` method, and defining and setting the arguments (and default values) of the service (both required and optional).

## Usage

Add the gem to your Gemfile:

```
gem 'service_interface', '~> 1.0'
```

Then create a service class, include the interface, and define the arguments, like so:

```ruby
class TestService
  include ServiceInterface

  arguments :word, count: 5, suffix: nil

  def execute
    (Array.new(@count, @word) << @suffix).compact.join(', ')
  end
end
```

Then invoke the class like so:

```
TestService.execute(word: 'Ruby', suffix: 'Yay!')
=> 'Ruby, Ruby, Ruby, Ruby, Ruby, Yay!'
```

The equivalent code, written without ServiceInterface, would look something like this:

```ruby
class TestService
  def self.execute(word:, count: 5, suffix: nil)
    new(
      word: word,
      count: count,
      suffix: suffix
    ).send(:execute)
  end

  def initialize(word:, count:, suffix:)
    @word = word
    @count = count
    @suffix = suffix
  end

  private

  def execute
    (Array.new(@count, @word) << @suffix).compact.join(', ')
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GlenCrawford/service_interface.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
