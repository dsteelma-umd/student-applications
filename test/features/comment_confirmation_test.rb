require 'test_helper'

feature 'Comment Confirmation page' do
  scenario 'go to the page and follow the change links', js: true do
    # we can fast-forward to the skills step
    fixture = prospects(:all_valid)
    all_valid = fixture.attributes
    all_valid[:enumeration_ids] = fixture.enumerations.map(&:id)
    all_valid.reject! { |a| %w(id created_at updated_at).include? a } 

    all_valid[:directory_id] = SecureRandom.hex
    all_valid[:semester] = "Fall 2017"
    all_valid[:available_hours_per_week] = 0

    all_valid[:addresses] = fixture.addresses
    all_valid[:phone_numbers] = fixture.phone_numbers

    page.set_rack_session("prospect_params": all_valid)
    page.set_rack_session("prospect_step": 'comments_confirmation')

    visit new_prospect_path
    assert page.has_content?('Confirmation')
    assert page.has_content?('Fall 2017')

    [ 'Applicant Info', 'Contact Info', 'Work Experience', 'Skills', 'Availability', 'Resume'].each do |step|
      
      click_link("Change #{step}")
      assert page.has_content?(step)
      # cycle back to the confirmation page
      10.times do
        click_button 'Continue'
        break if page.has_content?('Confirmation')
      end
    end
  end
end
