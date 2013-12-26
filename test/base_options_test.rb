require './test/test_helper.rb'

class OptionsStub
  include Raclette::BaseOptions

  def initialize
    @called = {}
  end

  attr_reader :called

  def opt_noArgs(options)
    @called[:noArgs] = true
    options
  end

  def opt_withArgs(arg, options)
    @called[:withArgs] = arg
    options
  end
end

describe Raclette::BaseOptions do
  it 'should call options methods' do
    stub = OptionsStub.new
    stub.load_options noArg: true, withArgs: 'RACLETTE DU FROMAGE'
    assert true, stub.called[:noArg]
    assert 'RACLETTE DU FROMAGE', stub.called[:withArgs]
  end
end
