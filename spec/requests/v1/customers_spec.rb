RSpec.describe '/v1/customers' do
  let(:response_hash) { JSON(response.body, symbolize_names: true) }

  describe 'GET to /' do
    it 'returns all customers' do
      customer = create(:customer)

      get v1_customers_path
      
      expect(response_hash).to eq(
        [
          {
            created_at: customer.created_at.iso8601(3),
            id: customer.id,
            updated_at: customer.updated_at.iso8601(3),
            first_name: customer.first_name,
            last_name: customer.last_name,
            address: customer.address,
            email: customer.email,
            phone: customer.phone
          }
        ]
      )
    end
  end

  describe 'GET to /:id' do
    context 'when found' do
      it 'returns a customer' do
        customer = create(:customer)

        get v1_customer_path(customer)

        expect(response_hash).to eq(
          {
            created_at: customer.created_at.iso8601(3),
            id: customer.id,
            updated_at: customer.updated_at.iso8601(3),
            first_name: customer.first_name,
            last_name: customer.last_name,
            address: customer.address,
            email: customer.email,
            phone: customer.phone
          }
        )
      end
    end

    context 'when not found' do
      it 'returns not_found' do
        get v1_customer_path(-1)

        expect(response).to be_not_found
      end
    end
  end

  describe 'POST to /' do
    context 'when successful' do
      let(:params) do
        {
          first_name: "Joe",
          last_name: "Schmo",
          address: "123 Fake Ln.",
          email: "abc@fake.net",
          phone: "1234567890"
        }
      end

      it 'creates a customer' do
        expect { post v1_customers_path, params: params }.to change { Customer.count }
      end

      it 'returns the created customer' do
        post v1_customers_path, params: params

        expect(response_hash).to include(params)
      end
    end

    context 'when there is no first name' do
      let(:params) do
        {
          first_name: "",
          last_name: "",
          address: "123 Fake Ln.",
          email: "abc@fake.net",
          phone: "123-456-7890"
        }
      end

      it 'returns an error' do
        post v1_customers_path, params: params

        expect(response_hash).to eq(
          {
            errors: [
              "First name can't be blank",
              "Last name can't be blank"
            ]
          }
        )
      end
    end

    context 'when there is no phone' do
      let(:params) do
        {
          first_name: "Joe",
          last_name: "Schmo",
          address: "123 Fake Ln.",
          email: "abc@fake.net",
          phone: ""
        }
      end

      it 'returns an error' do
        post v1_customers_path, params: params

        expect(response_hash).to eq(
          {
            errors: ["Phone should be at least 10 digits"]
          }
        )
      end
    end

    context 'when the phone is incorrect' do
      let(:params) do
        {
          first_name: "Joe",
          last_name: "Schmo",
          address: "123 Fake Ln.",
          email: "abc@fake.net",
          phone: "65743"
        }
      end

      it 'returns an error' do
        post v1_customers_path, params: params

        expect(response_hash).to eq(
          {
            errors: ["Phone should be at least 10 digits"]
            #check all errors
          }
        )
      end
    end

    context 'when the email is incorrect' do
      let(:params) do
        {
          first_name: "Joe",
          last_name: "Schmo",
          address: "123 Fake Ln.",
          email: "@wrong.bet",
          phone: "123-456-7890"
        }
      end

      it 'returns an error' do
        post v1_customers_path, params: params

        expect(response_hash).to eq(
          {
            errors: ["Email is not a valid format"]
            #check all errors
          }
        )
      end
    end

    context 'when there are nested attributes' do
      let(:params) do
        {
          first_name: "Joe",
          last_name: "Schmo",
          address: "123 Fake Ln.",
          email: "abc@fake.net",
          phone: "123-456-7890",
          vehicles_attributes: [{
            vin: "12EH1283919",
            mileage: 54678,
            make: "Honda",
            model: "Accord",
            color: "Blue",
            reservations_attributes: [{
              start_time: Time.now+1.day,
              end_time: Time.now+1.1.days
            }]
          }]
        }
      end

      it 'creates them correctly' do
        expect { post v1_customers_path, params: params }.to change { Customer.count }
                                                          .and change { Vehicle.count }
                                                          .and change { Reservation.count }
      end
    end
  end

  describe 'PUT to /:id' do
    let(:customer) { create(:customer) }

    context 'when successful' do
      let(:params) do
        {
          first_name: 'Jimbo'
        }
      end

      it 'updates an existing customer' do
        put v1_customer_path(customer), params: params

        expect(customer.reload.first_name).to eq(params[:first_name])
      end

      it 'returns the updated customer' do
        put v1_customer_path(customer), params: params

        expect(response_hash).to include(params)
      end
    end

    context 'when unsuccessful' do
      let(:params) do
        {
          first_name: ''
        }
      end

      it 'returns an error' do
        put v1_customer_path(customer), params: params

        expect(response_hash).to eq(
          {
            errors: ['First name can\'t be blank']
          }
        )
      end
    end

    context 'when there are nested attributes' do
      let(:customer) {
        Customer.create!(
        {
          first_name: "Joe",
          last_name: "Schmo",
          address: "123 Fake Ln.",
          email: "abc@fake.net",
          phone: "123-456-7890",
          vehicles_attributes: [{
            vin: "12EH1283919",
            mileage: 54678,
            make: "Honda",
            model: "Accord",
            color: "Blue",
            reservations_attributes: [{
              start_time: Time.now+1.day,
              end_time: Time.now+1.1.days
            }]
          }]
        })
      }
      let(:params) do
        {
          vehicles_attributes: [{
            id: customer.vehicles.first.id,
            mileage: 80000
          }]
        }
      end

      it 'updates them correctly' do
        put v1_customer_path(customer), params: params
        expect(customer.reload.vehicles.first.mileage).to eq(params[:vehicles_attributes][0][:mileage])
      end
    end
  end

  describe 'DELETE to /:id' do
    context 'when successful' do
      let(:customer) { create(:customer) }

      it 'deletes a customer' do
        customer
        expect { delete v1_customer_path(customer) }.to change { Customer.count }.from(1).to(0)
      end
    end

    context 'when not found' do
      it 'returns 404' do
        delete v1_customer_path(-1)

        expect(response).to be_not_found
      end
    end

    context 'when there are nested attributes' do
      let(:customer) do 
        Customer.create!(
        {
          first_name: "Joe",
          last_name: "Schmo",
          address: "123 Fake Ln.",
          email: "abc@fake.net",
          phone: "123-456-7890",
          vehicles_attributes: [{
            vin: "12EH1283919",
            mileage: 54678,
            make: "Honda",
            model: "Accord",
            color: "Blue",
            reservations_attributes: [{
              start_time: Time.now+1.day,
              end_time: Time.now+1.1.days
            }]
          }]
        })
      end

      it 'deletes them correctly' do
        customer
        expect { put v1_customer_path(customer), params: 
        {
          vehicles_attributes: [{
            id: customer.vehicles.first.id,
            mileage: 54678,
            make: "Honda",
            model: "Accord",
            color: "Blue",
            _destroy: 1,
            reservations_attributes: [{
              start_time: Time.now+1.day,
              end_time: Time.now+1.1.days
            }]
          }] 
        }
          }.to change { Vehicle.count }
          .and change { Reservation.count }
      end
    end
  end
end