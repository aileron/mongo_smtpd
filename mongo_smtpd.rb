#!ruby
# encoding: utf-8

#
# Mail一件の内容、MailBoxの子供として紐付く
#
class MailDocument
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :from
  field :subject
  field :data
end

#
# SMTPD として動作し、メール本文をmongoのドキュメントとして保存
#
class MailBox < EM::Protocols::SmtpServer
  include Mongoid::Document
  include Mongoid::Timestamps
  embeds_many :mail_documents

  #
  # メール受信時に、MongoDBに格納する
  #
  def receive_message
    p current
    box = MailBox.where :_id=> current.recipient
    box = MailBox.where :name=> current.recipient unless box

    if box
      box.mailboxes.create :from=>current.sender, :subject=>current.subject, :data => current.data
      current.received = true
      current.completed_at = Time.now
    else
      current.received = false
      current.completed_at = Time.now
    end
    return current.received
  end
end

if $0 == __FILE__
  MailBox.start 'localhost', 25
end
