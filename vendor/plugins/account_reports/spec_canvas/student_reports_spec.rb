#
# Copyright (C) 2013 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/report_spec_helper')

describe 'Student reports' do
  before do
    Notification.find_or_create_by_name('Report Generated')
    Notification.find_or_create_by_name('Report Generation Failed')
    @account = Account.default
    @course1 = course(:course_name => 'English 101', :account => @account,
                      :active_course => true)
    @course1.sis_source_id = 'SIS_COURSE_ID_1'
    @course1.save!
    @course1.offer
    @course2 = course(:course_name => 'Math 101', :account => @account,
                      :active_course => true)
    @course2.offer
    @course3 = Course.create(:name => 'Science 101', :course_code => 'SCI101',
                             :account => @account)
    @course3.offer
    @assignment1 = @course1.assignments.create!(:title => 'My Assignment')
    @assignment2 = @course2.assignments.create!(:title => 'My Assignment')
    @assignment3 = @course3.assignments.create!(:title => 'My Assignment')
    @assignment4 = @course3.assignments.create!(:title => 'My Assignment')
    @user1 = user_with_managed_pseudonym(
      :active_all => true, :account => @account, :name => 'John St. Clair',
      :sortable_name => 'St. Clair, John', :username => 'john@stclair.com',
      :sis_user_id => 'user_sis_id_01')
    @user2 = user_with_managed_pseudonym(
      :active_all => true, :username => 'micheal@michaelbolton.com',
      :name => 'Michael Bolton', :account => @account,
      :sis_user_id => 'user_sis_id_02')
    @user3 = user_with_managed_pseudonym(
      :active_all => true, :account => @account, :name => 'Rick Astley',
      :sortable_name => 'Astley, Rick', :username => 'rick@roll.com',
      :sis_user_id => 'user_sis_id_03')
    @course1.enroll_user(@user1, 'StudentEnrollment', {:enrollment_state => 'active'})
    @course2.enroll_user(@user2, 'StudentEnrollment', {:enrollment_state => 'active'})
    @course2.enroll_user(@user1, 'StudentEnrollment', {:enrollment_state => 'active'})
    @course1.enroll_user(@user2, 'StudentEnrollment', {:enrollment_state => 'active'})
    @section1 = @course1.course_sections.first
    @section2 = @course2.course_sections.first
    @section3 = @course3.course_sections.first
  end

  describe 'students with no submissions report' do
    before do
      @type = 'students_with_no_submissions_csv'
      @start_at = 2.months.ago
      @start_at2 = 10.days.ago
      @end_at = 1.day.ago

      @submission_time = 1.month.ago
      @assignment1.grade_student(@user1, {:grade => '4'})
      s = Submission.find_by_assignment_id_and_user_id(@assignment1.id, @user1.id)
      s.submitted_at = @submission_time
      s.save!

      @submission_time2 = 40.days.ago
      @assignment1.grade_student(@user2, {:grade => '5'})
      s = Submission.find_by_assignment_id_and_user_id(@assignment1.id, @user2.id)
      s.submitted_at = @submission_time2
      s.save!

      @assignment2.grade_student(@user1, {:grade => '9'})
      s = Submission.find_by_assignment_id_and_user_id(@assignment2.id, @user1.id)
      s.submitted_at = @submission_time2
      s.save!
    end

    it 'should find users that have not submitted anything after a date' do
      parameters = {}
      parameters['start_at'] = @start_at2
      parsed = ReportSpecHelper.run_report(@account,@type,parameters,[1,8])
      parsed.length.should == 4

      parsed[0].should == [@user1.id.to_s, 'user_sis_id_01',
                           @user1.sortable_name, @section1.id.to_s,
                           @section1.sis_source_id, @section1.name,
                           @course1.id.to_s, 'SIS_COURSE_ID_1', 'English 101']
      parsed[1].should == [@user1.id.to_s, 'user_sis_id_01',
                           @user1.sortable_name, @section2.id.to_s,
                           @section2.sis_source_id, @section2.name,
                           @course2.id.to_s, nil, 'Math 101']
      parsed[2].should == [@user2.id.to_s, 'user_sis_id_02',
                           'Bolton, Michael', @section1.id.to_s,
                           @section1.sis_source_id, @section1.name,
                           @course1.id.to_s, 'SIS_COURSE_ID_1', 'English 101']
      parsed[3].should == [@user2.id.to_s, 'user_sis_id_02',
                           'Bolton, Michael', @section2.id.to_s,
                           @section2.sis_source_id, @section2.name,
                           @course2.id.to_s, nil, 'Math 101']
    end

    it 'should find users that have not submitted anything after a date' do
      parameters = {}
      parameters['start_at'] = 45.days.ago
      parameters['end_at'] = 35.days.ago
      parsed = ReportSpecHelper.run_report(@account,@type,parameters,[1,8])
      parsed.length.should == 2

      parsed[0].should == [@user1.id.to_s, 'user_sis_id_01',
                           @user1.sortable_name, @section1.id.to_s,
                           @section1.sis_source_id, @section1.name,
                           @course1.id.to_s, 'SIS_COURSE_ID_1', 'English 101']
      parsed[1].should == [@user2.id.to_s, 'user_sis_id_02',
                           'Bolton, Michael', @section2.id.to_s,
                           @section2.sis_source_id, @section2.name,
                           @course2.id.to_s, nil, 'Math 101']
    end

    it 'should find users that have not submitted anything ever' do
      parsed = ReportSpecHelper.run_report(@account,@type,{},[1,8])
      parsed.length.should == 1

      parsed[0].should == [@user2.id.to_s, 'user_sis_id_02',
                           'Bolton, Michael', @section2.id.to_s,
                           @section2.sis_source_id, @section2.name,
                           @course2.id.to_s, nil, 'Math 101']
    end

    it 'should find users that have not submitted in a term' do
      @term1 = EnrollmentTerm.create(:name => 'Fall')
      @term1.root_account = @account
      @term1.save!
      @course1.enrollment_term = @term1
      @course1.save

      parameters = {}
      parameters['start_at'] = @start_at.to_s
      parameters['end_at'] = @end_at.to_s(:db)
      parameters['enrollment_term'] = @term1.id
      parsed = ReportSpecHelper.run_report(@account,@type,parameters,[1,8])

      parsed.length.should == 0
    end

    it 'should find users that have not submitted under a sub account' do
      @sub_account = Account.create(:parent_account => @account,
                                    :name => 'English')
      @course2.account = @sub_account
      @course2.save
      parsed = ReportSpecHelper.run_report(@sub_account,@type,{},[1,5])
      parsed.length.should == 1

      parsed[0].should == [@user2.id.to_s, 'user_sis_id_02',
                           'Bolton, Michael', @section2.id.to_s,
                           @section2.sis_source_id, @section2.name,
                           @course2.id.to_s, nil, 'Math 101']
    end

    it 'should find users that have not submitted for one course' do
      parameters = {}
      parameters['course'] = @course2.id
      parsed = ReportSpecHelper.run_report(@account,@type,parameters,[1,5])
      parsed.length.should == 1

      parsed[0].should == [@user2.id.to_s, 'user_sis_id_02',
                           'Bolton, Michael', @section2.id.to_s,
                           @section2.sis_source_id, @section2.name,
                           @course2.id.to_s, nil, 'Math 101']
    end
  end
end