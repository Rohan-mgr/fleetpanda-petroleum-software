require "rails_helper"

RSpec.describe Mutations::Drivers::EditDriver, type: :graphql do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization) }
  let!(:driver) { create(:driver, user: user, organization: organization) }

  it "is successful" do
    driver_info = {
      name: "Rajesh Rawan",
      email: "yopivob499@degcos.com",
      phone: "9866116627",
      status: "active"
  }

    ActsAsTenant.with_tenant(organization) do
      result = execute_graphql(edit_driver_query, variables: { id: driver.id, driverInfo: driver_info }, context: { current_user: user })
      expect(result.dig("data", "editDriver", "driver")).not_to be_nil
    end
  end

  def edit_driver_query
     <<~GQL
        mutation EditDrivers($id: ID!, $driverInfo: DriverInput!){
          editDriver(input:{id: $id, driverInfo: $driverInfo}){
            driver{
              id
              name
              email
              phone
              status
            }
            errors
            }
          }
      GQL
  end
end