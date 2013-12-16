require './test/test_helper.rb'

describe Raclette::Pipeout do
  it 'can store elements and retreive them' do
    pipe = Pipeout.new

    pipe[:test1] = 'test1'
    pipe[:test2] = 'test2'
    pipe[:test3] = 42
    pipe[:test4] = 37
    pipe[42_000] = 1337

    assert_equal 'test1', pipe[:test1]
    assert_equal 'test2', pipe[:test2]
    assert_equal 1337, pipe[42_000]
    assert_equal 42, pipe[:test3]
    assert_equal 37, pipe[:test4]
    assert_equal ['test2', 37, 42], pipe[:test2, :test4, :test3]
    assert_equal [ 42, 'test1', 37, 'test2', 1337], pipe[:test3, :test1, :test4, :test2, 42_000]
  end
end
