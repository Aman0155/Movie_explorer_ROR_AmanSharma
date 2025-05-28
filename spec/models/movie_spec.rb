require 'rails_helper'

RSpec.describe Movie, type: :model do
  let(:movie) { build(:movie) }
  let(:invalid_movie) { build(:movie, :invalid) }
  let(:movie_without_attachments) { build(:movie, :without_attachments) }
  let(:user_with_premium) { build(:user, subscription: build(:subscription, plan_type: 'premium')) }
  let(:user_without_premium) { build(:user, subscription: build(:subscription, plan_type: 'basic')) }
  let(:user_without_subscription) { build(:user, subscription: nil) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(movie).to be_valid
    end

    it "is not valid without a title" do
      movie.title = nil
      expect(movie).not_to be_valid
      expect(movie.errors[:title]).to include("can't be blank")
    end

    it "is not valid without a genre" do
      movie.genre = nil
      expect(movie).not_to be_valid
      expect(movie.errors[:genre]).to include("can't be blank")
    end

    it "is not valid with an invalid release year" do
      movie.release_year = 1800
      expect(movie).not_to be_valid
      expect(movie.errors[:release_year]).to include("must be greater than 1880")
    end

    it "is not valid with a release year beyond the current year" do
      movie = build(:movie, release_year: Date.current.year + 2)
      expect(movie).not_to be_valid
      expect(movie.errors[:release_year]).to include("must be less than or equal to #{Date.current.year}")
    end

    it "is valid with a rating within range" do
      movie.rating = 5
      expect(movie).to be_valid
    end

    it "is not valid with a rating above 10" do
      movie.rating = 11
      expect(movie).not_to be_valid
      expect(movie.errors[:rating]).to include("must be less than or equal to 10")
    end

    it "is not valid with a rating below 0" do
      movie.rating = -1
      expect(movie).not_to be_valid
      expect(movie.errors[:rating]).to include("must be greater than or equal to 0")
    end

    it "is valid with nil rating" do
      movie.rating = nil
      expect(movie).to be_valid
    end

    it "is not valid without a director" do
      movie.director = nil
      expect(movie).not_to be_valid
      expect(movie.errors[:director]).to include("can't be blank")
    end

    it "is not valid with a duration of 0 or less" do
      movie.duration = 0
      expect(movie).not_to be_valid
      expect(movie.errors[:duration]).to include("must be greater than 0")
    end

    it "is not valid without a description" do
      movie.description = nil
      expect(movie).not_to be_valid
      expect(movie.errors[:description]).to include("can't be blank")
    end

    it "is not valid if description exceeds 1000 characters" do
      movie.description = "a" * 1001
      expect(movie).not_to be_valid
      expect(movie.errors[:description]).to include("is too long (maximum is 1000 characters)")
    end

    it "is not valid with invalid attributes" do
      expect(invalid_movie).not_to be_valid
      expect(invalid_movie.errors[:title]).to include("can't be blank")
      expect(invalid_movie.errors[:genre]).to include("can't be blank")
      expect(invalid_movie.errors[:release_year]).to include("must be greater than 1880")
      expect(invalid_movie.errors[:rating]).to include("must be less than or equal to 10")
      expect(invalid_movie.errors[:director]).to include("can't be blank")
      expect(invalid_movie.errors[:duration]).to include("must be greater than 0")
      expect(invalid_movie.errors[:description]).to include("can't be blank")
    end

    it "is valid without poster attachment" do
      expect(movie_without_attachments).to be_valid
    end

    it "is not valid with invalid poster content type" do
      movie.poster.attach(io: StringIO.new("invalid"), filename: "invalid.txt", content_type: "text/plain")
      expect(movie).not_to be_valid
      expect(movie.errors[:poster]).to include("must be a JPEG or PNG image")
    end

    it "is valid without banner attachment" do
      expect(movie_without_attachments).to be_valid
    end

    it "is not valid with invalid banner content type" do
      movie.banner.attach(io: StringIO.new("invalid"), filename: "invalid.txt", content_type: "text/plain")
      expect(movie).not_to be_valid
      expect(movie.errors[:banner]).to include("must be a JPEG or PNG image")
    end

    # New validation edge case tests
    it "is valid with minimum release year (1881)" do
      movie.release_year = 1881
      expect(movie).to be_valid
    end

    it "is valid with current release year" do
      movie.release_year = Date.current.year
      expect(movie).to be_valid
    end

    it "is valid with minimum duration (1 minute)" do
      movie.duration = 1
      expect(movie).to be_valid
    end

    it "is valid with maximum description length (1000 characters)" do
      movie.description = "a" * 1000
      expect(movie).to be_valid
    end

    it "is valid with valid poster content type (JPEG)" do
      movie.poster.attach(io: StringIO.new("fake_image_data"), filename: "poster.jpg", content_type: "image/jpeg")
      expect(movie).to be_valid
    end

    it "is valid with valid banner content type (PNG)" do
      movie.banner.attach(io: StringIO.new("fake_image_data"), filename: "banner.png", content_type: "image/png")
      expect(movie).to be_valid
    end
  end

  describe "scopes" do
    let(:premium_movie) { create(:movie, premium: true) }
    let(:regular_movie) { create(:movie, premium: false) }

    it "filters premium movies" do
      expect(Movie.premium).to include(premium_movie)
      expect(Movie.premium).not_to include(regular_movie)
    end

    # New scope tests for accessible_to_user
    describe ".accessible_to_user" do
      it "returns all movies for a premium user" do
        expect(Movie.accessible_to_user(user_with_premium)).to include(premium_movie, regular_movie)
      end

      it "returns only non-premium movies for a basic user" do
        expect(Movie.accessible_to_user(user_without_premium)).to include(regular_movie)
        expect(Movie.accessible_to_user(user_without_premium)).not_to include(premium_movie)
      end

      it "returns only non-premium movies for a user without subscription" do
        expect(Movie.accessible_to_user(user_without_subscription)).to include(regular_movie)
        expect(Movie.accessible_to_user(user_without_subscription)).not_to include(premium_movie)
      end

      it "returns only non-premium movies for nil user" do
        expect(Movie.accessible_to_user(nil)).to include(regular_movie)
        expect(Movie.accessible_to_user(nil)).not_to include(premium_movie)
      end
    end
  end

  describe "attachment methods" do
    describe "#poster_attached?" do
      it "returns true when poster is attached" do
        movie.poster.attach(io: StringIO.new("fake_image_data"), filename: "poster.jpg", content_type: "image/jpeg")
        expect(movie.poster_attached?).to be true
      end

      it "returns false when poster is not attached" do
        expect(movie.poster_attached?).to be false
      end
    end

    describe "#banner_attached?" do
      it "returns true when banner is attached" do
        movie.banner.attach(io: StringIO.new("fake_image_data"), filename: "banner.png", content_type: "image/png")
        expect(movie.banner_attached?).to be true
      end

      it "returns false when banner is not attached" do
        expect(movie.banner_attached?).to be false
      end
    end
  end

  describe "ransack methods" do
    describe ".ransackable_associations" do
      it "returns the correct ransackable associations" do
        expect(Movie.ransackable_associations).to match_array(["banner_attachment", "banner_blob", "poster_attachment", "poster_blob"])
      end
    end

    describe ".ransackable_attributes" do
      it "returns the correct ransackable attributes" do
        expect(Movie.ransackable_attributes).to match_array(["title", "genre", "release_year", "director", "duration", "description", "premium", "rating"])
      end
    end
  end
end