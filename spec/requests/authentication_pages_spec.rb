require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit new_user_session_path }

    it { should have_selector('h2',    text: 'Sign in') }
    
    #Devise doesnt show title
    #it { should have_selector('title', text: 'Sign in') }
  end

  describe "signin" do
    before { visit new_user_session_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('h2', text: 'Sign in') }
      it { should have_selector('div.alert.alert-alert', text: 'Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-alert') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        user.confirm!
        fill_in "Email",    with: user.email
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      #todo
      #it { should have_selector('title', text: user.name) }
      
      it { should have_link('Users',    href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: destroy_user_session_path) }
      it { should have_link('Settings', href: edit_user_registration_path) }

      it { should_not have_link('Sign in', href: new_user_session_path) }
      
      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
  end
  
  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_registration_path }
          it { should have_selector('h2', text: 'Sign in') }
        end

        describe "submitting to the update action" do
          before { put edit_user_registration_path }
          specify { response.should redirect_to(new_user_session_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('h2', text: 'Sign in') }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_selector('h2', text: 'Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_selector('h2', text: 'Sign in') }
        end
      end

      describe "in the Microposts controller" do
        
        describe "submitting to the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(new_user_session_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(new_user_session_path) }
        end
      end

    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      # No longer a valid test as you can only update your self.
      # describe "visiting Users#edit page" do
      #  before { visit edit_user_registration_path }
      #  it { should_not have_selector('h2', text: full_title('Edit User')) }
      #end

      # No longer a valid test as you can only update your self.
      #describe "submitting a PUT request to the Users#update action" do
      #  before { put user_path(wrong_user) }
      #  specify { response.should redirect_to(root_path) }
      #end
    end

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before do
          user.confirm!
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end
        end
      end

      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { response.should redirect_to(new_user_session_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { response.should redirect_to(new_user_session_path) }          
        end
      end
    end
 
    #todo not implemented admin
    #describe "as non-admin user" do
    #  let(:user) { FactoryGirl.create(:user) }
    #  let(:non_admin) { FactoryGirl.create(:user) }

    #  before { sign_in non_admin }

    #  describe "submitting a DELETE request to the Users#destroy action" do
    #    before { delete user_path(user) }
    #    specify { response.should redirect_to(root_path) }        
    #  end
    #end

    
  end

end
