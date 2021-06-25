require 'pry'
require 'time'

class String
  def true?
    self.to_s.downcase == "true"
  end
end

class Array
  def includes_all?(values)
    values.all? { |x| self.include?(x) }
  end

  def to_formatted_hash
    if self.includes_all? ['proposal', 'created']
      {
        event_id: self[0],
        event_schema: self[1],
        event_action: self[2],
        event_timestamp: self[3],
        proposal_id: self[4],
        proposal_loan_value: self[5],
        proposal_number_of_monthly_installments: self[6].gsub("\n", '')
      }
    elsif self.includes_all? ['proposal', 'updated']
      {
        event_id: self[0],
        event_schema: self[1],
        event_action: self[2],
        event_timestamp: self[3],
        proposal_id: self[4],
        proposal_loan_value: self[5],
        proposal_number_of_monthly_installments: self[6].gsub("\n", '')
      }
    elsif self.includes_all? ['proposal', 'deleted']
      {
        event_id: self[0],
        event_schema: self[1],
        event_action: self[2],
        event_timestamp: self[3],
        proposal_id: self[4].gsub("\n", '')
      }
    elsif self.includes_all? ['warranty', 'added']
      {
        event_id: self[0],
        event_schema: self[1],
        event_action: self[2],
        event_timestamp: self[3],
        proposal_id: self[4],
        warranty_id: self[5],
        warranty_value: self[6],
        warranty_province: self[7].gsub("\n", '')
      }

    elsif self.includes_all? ['warranty', 'updated']
      {
        event_id: self[0],
        event_schema: self[1],
        event_action: self[2],
        event_timestamp: self[3],
        proposal_id: self[4],
        warranty_id: self[5],
        warranty_value: self[6],
        warranty_province: self[7].gsub("\n", '')
      }
    elsif self.includes_all? ['warranty', 'removed']
      {
        event_id: self[0],
        event_schema: self[1],
        event_action: self[2],
        event_timestamp: self[3],
        proposal_id: self[4],
        warranty_id: self[5].gsub("\n", '')
      }
    elsif self.includes_all? ['proponent', 'added']
      {
        event_id: self[0],
        event_schema: self[1],
        event_action: self[2],
        event_timestamp: self[3],
        proposal_id: self[4],
        proponent_id: self[5],
        proponent_name: self[6],
        proponent_age: self[7],
        proponent_monthly_income: self[8],
        proponent_is_main: self[9].gsub("\n", '')
      }
    elsif self.includes_all? ['proponent', 'updated']
      {
        event_id: self[0],
        event_schema: self[1],
        event_action: self[2],
        event_timestamp: self[3],
        proposal_id: self[4],
        proponent_id: self[5],
        proponent_name: self[6],
        proponent_age: self[7],
        proponent_monthly_income: self[8],
        proponent_is_main: self[9].gsub("\n", '')
      }
    elsif self.includes_all? ['proponent', 'removed']
      {
        event_id: self[0],
        event_schema: self[1],
        event_action: self[2],
        event_timestamp: self[3],
        proposal_id: self[4],
        proponent_id: self[5].gsub("\n", '')
      }
    end
  end
end

class Proposal
  attr_accessor :id, :timestamp, :loan_value, :monthly_installments, :proponents, :warranties, :valid

  def initialize(id, timestamp, loan_value, monthly_installments)
    self.id = id
    self.timestamp = timestamp
    self.loan_value = loan_value
    self.monthly_installments = monthly_installments
    @proponents = []
    @warranties = []
    @valid = nil
  end

  def dispatch_event(schema, action, args)
    if schema == 'warranty' && action == 'added'
      add_warranty(*args)
    elsif schema == 'warranty' && action == 'updated'
      update_warranty(*args)
    elsif schema == 'warranty' && action == 'removed'
      remove_warranty(args) # id 
    elsif schema == 'proponent' && action == 'added'
      add_proponent(*args)
    elsif schema == 'proponent' && action == 'updated'
      update_proponent(*args)
    elsif schema == 'proponent' && action == 'removed'
      remove_proponent(args) # id
    end
  end

  def add_warranty(id, value, province)
    unless ['PR', 'SC', 'RS'].include? province
      self.warranties << {id: id, value: value.to_f, province: province}
    end
  end
  
  def update_warranty(id, value, province)
    warranty = self.warranties.find { |warranty| warranty[:id] == id }
    warranty[:value] = value.to_f
    warranty[:province] = province
  end
  
  def remove_warranty(id)
    warranty = self.warranties.find { |warranty| warranty[:id] == id }
    self.warranties.delete(warranty)
  end

  def add_proponent(id, name, age, monthly_income, is_main)
    self.proponents << {id: id, name: name, age: age.to_i, monthly_income: monthly_income.to_f, is_main: is_main.true?}
  end

  def update_proponent(id, name, age, monthly_income, is_main)
    proponent = self.proponents.find { |proponent| proponent[:id] == id }
    proponent[:name] = name
    proponent[:age] = age.to_i
    proponent[:monthly_income] = monthly_income.to_f
    proponent[:is_main] = is_main.true?
  end

  def remove_proponent(id)
    proponent = self.proponents.find { |proponent| proponent[:id] == id }
    self.proponents.delete(proponent)
  end

  ## VALIDATIONS

  def is_loan_in_value_range?
    self.loan_value.to_f.between?(30000, 3000000)
  end

  def is_loan_in_time_range?
    self.monthly_installments.to_i.between?(24, 180)
  end

  def there_are_two_proponents?
    self.proponents.size >= 2
  end

  def there_is_only_one_main_proponent?
    (self.proponents.find { |proponent| proponent[:is_main] == true }).class == Hash
  end

  def are_all_proponents_of_age?
    (self.proponents.select {|proponent| proponent[:age] >= 18 }).size == @proponents.size
  end
  
  def there_is_an_warranty_property?
    self.warranties.any?
  end

  def are_warranties_total_equal_or_bigger_than_loan?
    warranties_total = []
    self.warranties.each {|warranty| warranties_total << warranty[:value]}
    self.warranties.size > 0 ? warranties_total.reduce(:+) >= self.loan_value.to_f * 2 : false
  end

  def is_main_proponent_income_valid?
    main_proponent = self.proponents.find { |proponent| proponent[:is_main] == true }
    unless main_proponent == nil
      if main_proponent[:age].between?(18, 24)
        main_proponent[:monthly_income] >= self.loan_value.to_f * 4
      elsif main_proponent[:age].between?(24,50)
        main_proponent[:monthly_income] >= self.loan_value.to_f * 3
      elsif main_proponent[:age] > 50
        main_proponent[:monthly_income] >= self.loan_value.to_f * 2
      end
    end
  end
end

class Solution
  def process_messages(messages)

    @events = []
    
    messages.each do |event|
      data = event.split(',')
      @events << data.to_formatted_hash
    end

    @proposals = []
    @logged_events = []
    
    @events.each do |event|
      # manage proposals
      unless  event[:event_schema] == 'proposal' && event[:event_action] == 'created' ||
              event[:event_schema] == 'proposal' && event[:event_action] == 'updated' ||
              event[:event_schema] == 'proposal' && event[:event_action] == 'deleted' ||
              @events.first[:event_id] == event[:event_id] ||
              @logged_events.any? {|logged_event| logged_event[:event_id] == event[:event_id]} || # discards repetition
              @logged_events.any? {|logged_event| logged_event[:event_schema] == event[:event_schema] && # discards older events
                                                  logged_event[:event_action] == event[:event_action] &&
                                                  Time.parse(logged_event[:event_timestamp]) < Time.parse(event[:event_timestamp])  }
              
        # code
        proposal = @proposals.find { |proposal| proposal.id == event[:proposal_id] }
        args = event.except(:event_id, :event_schema, :event_action, :event_timestamp, :proposal_id)
        args = args.map {|arg| arg[1]}
        proposal.dispatch_event(event[:event_schema], event[:event_action], args) unless proposal == nil
      else
        args = event.except(:event_id, :event_schema, :event_action)
        args = args.map {|arg| arg[1]}
        dispatch_proposal(event[:event_action], args) if event[:event_schema] == 'proposal'
      end
      # log event
      @logged_events << event  
    end
    # binding.pry
    set_valid_proposals
    generate_output
  end

  def dispatch_proposal(action, args)
    if action == 'created'
      @proposals << Proposal.new(args[1], args[0], args[2], args[3])
    elsif action == 'updated'
      binding.pry
      proposal = @proposals.find { |proposal| proposal.id == args[1] }
      proposal.id = args[1]

    elsif action == 'deleted'
      remove_warranty(*args)
    end
  end

  def set_valid_proposals
    @proposals.each do |proposal|
      if  proposal.is_loan_in_value_range?
          proposal.is_loan_in_time_range?
          proposal.there_are_two_proponents?
          proposal.there_is_only_one_main_proponent?
          proposal.are_all_proponents_of_age?
          proposal.there_is_an_warranty_property?
          proposal.are_warranties_total_equal_or_bigger_than_loan?
          proposal.is_main_proponent_income_valid?
      
          proposal.valid = true
      else
          proposal.valid = false
      end
    end
  end

  def generate_output
    output = []
    @proposals.each do |proposal|
      if proposal.valid == true
        output << proposal.id
      end
    end
    output.join(',')
  end
end
