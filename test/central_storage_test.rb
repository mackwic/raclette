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
    nb = 30
    threads = []
    count = CountDownLatch.new nb

    CentralStorage.store 'global', "RACLETTE DU FROMAGE"

    nb.times do |i|
      threads << Thread.new do
        CentralStorage.store "a#{i}", 3 + i
        CentralStorage.store "b#{i}", 4 + i
        CentralStorage.store (2+i), 1 + i

        count.count_down
        count.wait

        res = true
        res &&= (3 + i == CentralStorage.retreive("a#{i}"))
        res &&= (4 + i == CentralStorage.retreive("b#{i}"))
        res &&= ((1+i) == CentralStorage.retreive(2+i))
        res &&= ('RACLETTE DU FROMAGE' == CentralStorage.retreive('global'))
      end
    end

    threads.each {|t| assert t.value}
  end
end
