# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(100) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
    it { should validate_presence_of(:mobile_number) }
    it { should validate_uniqueness_of(:mobile_number).case_insensitive }
    it { should allow_value('+12345678901').for(:mobile_number) }
    it { should_not allow_value('12345').for(:mobile_number) }
  end

  describe 'associations' do
    it { should have_one(:subscription).dependent(:destroy) }
    it { should have_many(:wishlists).dependent(:destroy) }
    it { should have_many(:wishlist_movies).through(:wishlists) }
  end

  describe 'scopes' do
    let!(:supervisor) { create(:user, role: :supervisor) }
    let!(:new_user) { create(:user, created_at: 1.day.ago) }
    
    it '.by_role returns users with specified role' do
      expect(User.by_role(:supervisor)).to eq([supervisor])
    end
    
    it '.recent returns users ordered by creation time' do
      expect(User.recent.first).to eq(user)
    end
  end

  describe 'callbacks' do
    it 'creates default subscription after create' do
      expect { create(:user) }.to change(Subscription, :count).by(1)
    end

    it 'handles Stripe errors during subscription creation' do
      allow(Stripe::Customer).to receive(:create).and_raise(Stripe::StripeError)
      expect { create(:user) }.to change(Subscription, :count).by(1)
    end
  end

  describe 'devise jwt' do
    it 'includes role in jwt payload' do
      expect(user.jwt_payload).to include('role' => user.role)
    end
  end

  describe 'ransack' do
    it 'returns searchable attributes' do
      expect(User.ransackable_attributes).to include('name', 'email', 'mobile_number')
    end
    
    it 'returns searchable associations' do
      expect(User.ransackable_associations).to include('subscription', 'wishlists')
    end
  end
end
# require 'rails_helper'

# RSpec.describe User, type: :model do
#   let(:user) { build(:user) }
#   let(:invalid_user) { build(:user, :invalid) }

#   describe "validations" do
#     it "is valid with valid attributes" do
#       expect(user).to be_valid
#     end

#     it "is not valid without a name" do
#       user.name = nil
#       expect(user).not_to be_valid
#       expect(user.errors[:name]).to include("can't be blank")
#     end

#     it "is not valid if name is too short" do
#       user.name = "ab"
#       expect(user).not_to be_valid
#       expect(user.errors[:name]).to include("is too short (minimum is 3 characters)")
#     end

#     it "is not valid if name is too long" do
#       user.name = "a" * 101
#       expect(user).not_to be_valid
#       expect(user.errors[:name]).to include("is too long (maximum is 100 characters)")
#     end

#     it "is not valid without a mobile number" do
#       user.mobile_number = nil
#       expect(user).not_to be_valid
#       expect(user.errors[:mobile_number]).to include("can't be blank")
#     end

#     it "is not valid with an invalid mobile number format" do
#       user.mobile_number = "123"
#       expect(user).not_to be_valid
#       expect(user.errors[:mobile_number]).to include("is invalid")
#     end

#     it "is not valid with a duplicate mobile number" do
#       create(:user, mobile_number: "+1234567890")
#       duplicate_user = build(:user, mobile_number: "+1234567890")
#       expect(duplicate_user).not_to be_valid
#       expect(duplicate_user.errors[:mobile_number]).to include("has already been taken")
#     end

#     it "is not valid without an email" do
#       user.email = nil
#       expect(user).not_to be_valid
#       expect(user.errors[:email]).to include("can't be blank")
#     end

#     it "is not valid with an invalid email format" do
#       user.email = "invalid-email"
#       expect(user).not_to be_valid
#       expect(user.errors[:email]).to include("is invalid")
#     end

#     it "is not valid with a duplicate email" do
#       create(:user, email: "john@example.com")
#       duplicate_user = build(:user, email: "john@example.com")
#       expect(duplicate_user).not_to be_valid
#       expect(duplicate_user.errors[:email]).to include("has already been taken")
#     end

#     it "is not valid with a password that is too short" do
#       user.password = "short"
#       expect(user).not_to be_valid
#       expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
#     end

#     it "is not valid without a password on creation" do
#       user.password = nil
#       expect(user).not_to be_valid
#       expect(user.errors[:password]).to include("can't be blank")
#     end

#     it "is not valid with an invalid role" do
#       expect { user.role = "invalid_role" }.to raise_error(ArgumentError, "'invalid_role' is not a valid role")
#     end

#     it "is not valid with invalid attributes" do
#       expect(invalid_user).not_to be_valid
#       expect(invalid_user.errors[:email]).to include("is invalid")
#       expect(invalid_user.errors[:password]).to include("can't be blank")
#       expect(invalid_user.errors[:name]).to include("can't be blank", "is too short (minimum is 3 characters)")
#       expect(invalid_user.errors[:mobile_number]).to include("can't be blank")
#     end
#   end

#   describe "callbacks" do
#     it "downcases the email before validation" do
#       user.email = "TestUser@Example.com"
#       user.valid?
#       expect(user.email).to eq("testuser@example.com")
#     end
#   end

#   describe "Devise and JWT functionality" do
#     it "is valid with a unique jti" do
#       user = create(:user)
#       expect(user.jti).to be_present
#     end

#     it "includes role in JWT payload" do
#       user = create(:user, role: :supervisor)
#       payload = user.jwt_payload
#       expect(payload).to eq('role' => 'supervisor')
#     end
#   end

#   describe "role enum" do
#     it "defines user and supervisor roles" do
#       expect(User.roles).to eq("user" => 0, "supervisor" => 1)
#     end

#     it "sets default role to user" do
#       user = create(:user)
#       expect(user.role).to eq("user")
#     end

#     it "allows role to be supervisor" do
#       user = create(:user, :supervisor)
#       expect(user.role).to eq("supervisor")
#     end
#   end

#   describe "scopes" do
#     it "filters users by role" do
#       user1 = create(:user, role: :user)
#       user2 = create(:user, role: :supervisor)
#       expect(User.by_role(:supervisor)).to include(user2)
#       expect(User.by_role(:supervisor)).not_to include(user1)
#     end

#     it "orders users by recent creation" do
#       older_user = create(:user, created_at: 2.days.ago)
#       newer_user = create(:user, created_at: 1.day.ago)
#       expect(User.recent.first).to eq(newer_user)
#       expect(User.recent.last).to eq(older_user)
#     end
#   end

#   describe "ransackable attributes and associations" do
#     it "defines ransackable attributes" do
#       expect(User.ransackable_attributes).to match_array(["created_at", "email", "id", "name", "mobile_number", "role", "updated_at"])
#     end

#     it "defines ransackable associations" do
#       expect(User.ransackable_associations).to eq([])
#     end
#   end
# end