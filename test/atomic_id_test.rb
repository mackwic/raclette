require './test/test_helper.rb'
require 'thread'

describe Raclette::AtomicId do

  it 'should increment itself' do
    id = AtomicId.new
    assert_equal 1, id.incr
    assert_equal 2, id.get
    assert_equal 3, id.a_incr
    assert_equal 4, id.a_get
    assert_equal 5, id.get
  end

  it 'can track multilpe ids in the same time' do
    id1, id2 = AtomicId.new, AtomicId.new
    assert_same id1.incr, id2.incr
    assert_same id1.get, id2.get
    assert_same id1.a_incr, id2.a_incr
    assert_same id1.a_get, id2.a_get
    assert_same id1.incr, id2.incr
  end

  it 'is thread safe' do
    nb = 30
    id = AtomicId.new
    count = CountDownLatch.new nb
    ids = {}
    threads = []

    nb.times do |i|
      threads << Thread.new(i, id, ids) do |i, id, ids|
        myself = ids[i] = id.incr

        count.count_down
        count.wait
        result = true

        ids.each do |k, v|
          if k == i
            result &&= (v == myself)
          else
            result &&= (v != myself)
          end
        end
        result
      end
    end

    threads.each {|t| assert t.value }
  end
end
