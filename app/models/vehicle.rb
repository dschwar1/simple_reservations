class Vehicle < ApplicationRecord
    #Relationships
    belongs_to :customer
    has_many :reservations, dependent: :destroy, inverse_of: :vehicle
    accepts_nested_attributes_for :reservations, reject_if: :all_blank, allow_destroy: true

    #Validations
    validates_presence_of :vin, :make, :model, :color
    validates_associated :reservations

    #Methods

    private

end
