RSpec.describe ServiceInterface do
  # Set up a test service class to test the interface module.
  before do
    stub_const 'TestService', Class.new

    TestService.class_eval do
      include ServiceInterface

      arguments :word, count: 5, suffix: nil

      def execute
        (Array.new(@count, @word) << @suffix).compact.join(', ')
      end
    end
  end

  let(:word) { 'Ruby' }
  let(:count) { 10 }
  let(:suffix) { '!!!' }

  let(:expected_result) do
    (Array.new(count, word) << suffix).compact.join(', ')
  end

  describe '.execute' do
    describe 'arguments' do
      context 'all arguments are specified (required and non-required)' do
        it 'works' do
          expect(TestService.execute(word: word, count: count, suffix: suffix)).to eq expected_result
        end
      end

      context 'only required arguments are specified' do
        let(:count) { 5 }
        let(:suffix) { nil }

        it 'works' do
          expect(TestService.execute(word: word)).to eq expected_result
        end
      end

      context 'not specifying an optional argument that has a default value of nil' do
        let(:suffix) { nil }

        it 'works' do
          expect(TestService.execute(word: word, count: count)).to eq expected_result
        end
      end

      context 'a required argument is not specified' do
        it 'raises an error' do
          expect { TestService.execute(count: count, suffix: suffix) }.to raise_error(ArgumentError, 'Required arguments (with no default value) not specified: word')
        end
      end

      context 'an undeclared argument is specified' do
        it 'raises an error' do
          expect { TestService.execute(word: word, count: count, suffix: suffix, invalid_argument: 'invalid argument value') }.to raise_error(ArgumentError, "Unrecognized arguments specified: invalid_argument")
        end
      end
    end
  end

  describe '#execute' do
    describe 'preventing the service from being initialized manually and the execute class method being bypassed' do
      let(:service_instance) { TestService.new(word: word, count: count, suffix: suffix) }

      it 'raises an error' do
        expect { service_instance.execute }.to raise_error(NoMethodError, /private method `execute' called/)
      end
    end
  end
end
