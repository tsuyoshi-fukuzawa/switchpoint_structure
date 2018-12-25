class PerformanceCheckService < ApplicationService
  # rails runnerから実行して確認することを想定

  def initialize
  end

  def self.check_elaps_select_by_master
    start_time = Time.now
    min_id = DogParent.all.minimum(:id)
    max_id = DogParent.all.maximum(:id)

    dummy_sum = 0
    500.times do 
      select_id = rand(min_id..max_id)
      dog = DogParent.where(id: select_id).first
      dummy_sum += dog.id
    end
    p "SELECT ELAPS: #{Time.now - start_time}"
  end

  def self.check_elaps_select_by_slave
    ApplicationRecord.with_readonly do
      start_time = Time.now
      min_id = DogParent.all.minimum(:id)
      max_id = DogParent.all.maximum(:id)

      dummy_sum = 0
      500.times do 
        select_id = rand(min_id..max_id)
        dog = DogParent.where(id: select_id).first
        dummy_sum += dog.id
      end
      p "SELECT ELAPS: #{Time.now - start_time}"
    end
  end

  def self.check_elaps_select_by_master_and_slave
    start_time = Time.now
    min_id = DogParent.all.minimum(:id)
    max_id = DogParent.all.maximum(:id)

    dummy_sum = 0
    500.times do 
      @select_id = rand(min_id..max_id)
      if @select_id.even?
        ApplicationRecord.with_readonly do
          @dog = DogParent.where(id: @select_id).first
        end
      else
        @dog = DogParent.where(id: @select_id).first
      end
      dummy_sum += @dog.id
    end
    p "SELECT ELAPS: #{Time.now - start_time}"
  end

  def self.test_data_insert
    start_time = Time.now
    ApplicationRecord.transaction do
      10000.times do |i|
        dog = DogParent.new
        dog.name = i.to_s
        dog.save!
      end
    end
    p "INSERT ELAPS: #{Time.now - start_time}"
  end

  def self.test_data_delete
    start_time = Time.now
    ApplicationRecord.transaction do
      DogParent.all.each do |dog|
        dog.destroy!
      end
    end
    p "DELETE ELAPS: #{Time.now - start_time}"
  end
end
