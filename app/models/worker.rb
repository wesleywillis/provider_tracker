class Worker < ActiveRecord::Base
  has_and_belongs_to_many :clients, :join_table => :care_pairs

  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true

  def full_street_address
    [address, city, state].compact.join(', ')
  end

  geocoded_by :full_street_address   # can also be an IP address
  after_validation :geocode          # auto-fetch coordinates
  after_save :geocode
end
