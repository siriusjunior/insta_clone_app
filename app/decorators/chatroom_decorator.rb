class ChatroomDecorator < ApplicationDecorator
  delegate_all

  def message_text
    messages.last&.body&.truncate(30) || 'メッセージがありません'
  end

end
