class Reservation < ApplicationRecord
    #Relationships
    belongs_to :vehicle

    #Validations
    validates_presence_of :start_time, :end_time
    validate :start_before_end
    validate :no_reservation_overlap

    #Methods

    private
    def start_before_end
        return if start_time.nil? || end_time.nil?
        if self.start_time > self.end_time
            errors.add(:end_time, "can't be before start time")
            return false
        end
        true
    end

    def no_reservation_overlap #could probably refactor this 
        return if start_time.nil? || end_time.nil? || vehicle.nil?
        time_ranges = self.vehicle.reservations.where.not(id: self.id).order(:start_time)
        return if time_ranges.blank?
        time_ranges.each do |range|
            if((self.end_time > range.start_time && self.end_time < range.end_time) ||
               (self.start_time > range.start_time && self.start_time < range.end_time))
                errors.add(:base, "Time Ranges for this vehicle can't overlap")
                return false
            end
        end
        true
    end
end
