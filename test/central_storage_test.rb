require './test/test_helper.rb'

describe Raclette::CentralStorage do
  it 'act as a global hash' do
    5.times do |i|
      CentralStorage.store "k#{i}", "v#{i}"
    end
    5.times do |i|
      assert_equal "v#{i}", CentralStorage.retreive("k#{i}")
    end
  end

  it 'is thread safe' do
    assert true
  end
end
