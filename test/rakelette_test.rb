require './test/test_helper.rb'

describe Raclette::Rakelette do

  before do
    Rakelette.register_scraper(Object, ['arg'], proc {puts 'THIS MUST NOT BE DISPLAYED'})
  end

  let(:tasks)       {Rake.application.tasks}
  let(:tasks_names) {Rake.application.tasks.map(&:name)}
  let(:tasks_args)  {Rake.application.tasks.map(&:arg_names)}

  after do
    Rake.application.clear
  end

  it 'should register scraper tasks' do
    @i = 0
    fake_sraper = proc {@i = 42}

    Rakelette.register_scraper(Object, ['first', 'second', 'third'], fake_sraper)

    assert_includes tasks_names, "scrape:object:with_arg"
    assert_includes tasks_names, "scrape:object:with_first"
    assert_includes tasks_args, [:first, :second, :third], 'arguments badly declared !'
    assert_equal 0, @i, 'job was executed !'
    assert_includes tasks_names, 'scrape:object:all', 'it should be able to scrap\'em all'
    assert_includes tasks_names, 'scrape:all', 'it should be able to scrap\'em all'
  end

  it 'should register export tasks' do
    assert_includes tasks_names, 'export:objet'
    assert_includes tasks_names, 'export:all'
    assert false, 'TODO: test really the export with fake data'
  end

  it 'should register matcher tasks' do
    assert_includes tasks_names, 'match:object'
    assert_includes tasks_names, 'match:all'
    assert false, 'TODO: test really the matching with fake data'
  end
end
