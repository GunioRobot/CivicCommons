Given /^I am on the (\w+) index page/ do |resource|
  visit send("#{resource.downcase.pluralize}_url")
end

Given /^I have a confirmed local user account$/ do
  @current_person = Factory.create(:registered_user)
end

Given /^I am logged in$/ do
  visit '/people/login'
  fill_in 'person[email]', with: @current_person.email
  fill_in 'person[password]', with: 'password'
  click_button 'person_submit'
end

Then /^I should receive an? "([^"]*)" with the message:$/ do |error, string|
  @code_to_run.should raise_error(error.constantize, string)
end

Then /(|not) see (?:the|an?) "([^"]*)" link/ do |no, name|
  assertion = have_link(name)
  page.send(no.blank? ? :should : :should_not, assertion)
end

Then /(|not) see (?:the|an?) "([^"]*)" button$/ do |no, name|
  assertion = have_selector(:xpath, ".//button[@text='#{name}']",".//a[@text='#{name}']",".//input[@type='submit'][@value='#{name}']")
  page.send(no.blank? ? :should : :should_not)
end

Then /(|not) see (?:the|an?) "([^"]*)" submit button$/ do |no, name|
  assertion = have_selector("input[type=submit][value='#{name}']")
  page.send(no.blank? ? :should : :should_not, assertion)
end

Then /(|not) see (?:the|an?) "([^"]*)" text (box|area)$/ do |no, name, el|
  assertion = have_field(name)
  page.send(no.blank? ? :should : :should_not, assertion)
end

