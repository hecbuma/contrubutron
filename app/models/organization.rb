class Organization < ActiveRecord::Base
  include AASM

  has_and_belongs_to_many :users
  has_and_belongs_to_many :members, dependent: :destroy

  aasm do
    state :created, :initial => true
    state :fetching
    state :failed
    state :completed

    event :fetch do
      transitions :from => [:created, :failed], :to => :fetching
    end

    event :fail do
      transitions :from => :fetching, :to => :failed
    end

    event :complete do
      transitions :from => :fetching, :to => :completed
    end
  end

  def move_to_queue
    self.fetch!
    QueryJob.perform_later self
  end

  def fetch_data
    begin
      puts "the magic is gonna happen here "
    rescue => e
      self.fail!
      message = ""
      message << e.message
      message << e.backtrace.join("\n")
      errors[:error] = message
      Rails.logger.info message
    end
    self.complete! if errors.empty?
  end

end
