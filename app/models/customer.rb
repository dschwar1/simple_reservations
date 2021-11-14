class Customer < ApplicationRecord
    #Callbacks
    before_validation :format_phone

    #Relationships
    has_many :vehicles, dependent: :destroy, inverse_of: :customer
    accepts_nested_attributes_for :vehicles, reject_if: :all_blank, allow_destroy: true
    has_many :reservations, through: :vehicles
    #One thing to note here is that customers could potentially sell their vehicles
    ##and in the future another customer could bring in the same vehicle, causing
    ##there to be 2 vehicle records with the same VIN in the database.
    #You could solve this by just changing the foreign key in the Vehicles table,
    ##but if you want to keep track of all previous owners you'd need a join table
    ##and some a few methods and validation make sure there's only 1 active owner
    ##and be able to call them easily

    #Validations
    validates_presence_of :first_name, :last_name
    #Really simple phone validation. In a real API, I'd probably want to sanitize any input
    ##to be 10 digits with country code and store that in the database
    #I think formatting the number to be readable would be a frontend issue but I'm not sure
    ##it could be done to just add a couple methods here to reformat the numbers when
    ##serving them out instead
    validates :phone, format: { with: /\A\d{10}\z/, message: "should be at least 10 digits", allow_blank: false }
    validates :email, presence: false, format: { with: /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i, message: "is not a valid format" }
    validates_associated :vehicles

    #Methods

    private
    #This only removes some common punctuation and shortens phone numbers to 10 digits(local only)
    def format_phone
        return false if phone.nil?
        new_num = phone
        new_num = new_num.gsub(/[\(\)-. ]/, "")
        self.phone = new_num[-10..-1]
        true
    end
end
