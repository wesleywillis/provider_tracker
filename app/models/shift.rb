class Shift < ActiveRecord::Base
  belongs_to :carepair

  def start_in_range?
    care_pair = self.care_pair_id
    client = CarePair.find(care_pair).client
    client_gps = []
    client_gps.push(client.latitude, client.longitude)
    shift_gps_string = self.start_gps.split
    shift_gps = shift_gps_string.map! { |x| x.to_f }
    range = Geocoder::Calculations.distance_between(client_gps, shift_gps)
    if range < 1
      self.update(start_range: true)
    elsif range > 1
      self.update(start_range: false)
    end
  end

  def stop_in_range?
    care_pair = self.care_pair_id
    client = CarePair.find(care_pair).client
    client_gps = []
    client_gps.push(client.latitude, client.longitude)
    shift_gps_string = self.start_gps.split
    shift_gps = shift_gps_string.map! { |x| x.to_f }
    range = Geocoder::Calculations.distance_between(client_gps, shift_gps)
    if range < 1
      self.update(stop_range: true)
    elsif range > 1
      self.update(stop_range: false)
    end
  end

  def total_range?
    if (self.start_range == true && self.stop_range == true)
      self.update(final_range: true)
    else
      self.update(final_range: false, alert_admin: true)
      self.update(alert_admin: true)
      self.update(alert_table: false)
    end
  end

  def shift_length
    self.update(shift_minutes: ((self.updated_at - self.created_at)/60.0))
  end

  def self.collect_bad_shifts
    Shift.where(alert_admin: true && alert_table: true)
  end

  def dismiss_shift_alert
    self.update(alert_admin: false)
  end
end
