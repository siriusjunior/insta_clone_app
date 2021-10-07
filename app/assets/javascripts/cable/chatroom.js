$(function(){
    if($("#chatroom").length > 0){
        const chatroomId = $("#chatroom").data("chatroomId")
        const currentUserId = $("#chatroom").data("currentUserId")
        const formUserId = $("#form").data("formUserId")

        App.chatrooms = App.cable.subscriptions.create({ channel: "ChatroomChannel", chatroom_id: chatroomId }, { 
            connected: function(){
                console.log("connected")
            },
            disconnected: function(){
                console.log("disconnected")
            }, 
            received: function(data) {
                switch(data.type) {
                    case "create":
                        $('#message-box').append(data.html);
                        if( $(`#message-${data.message.id}`).data("senderId") != currentUserId ){
                            // 送信部のidとルーム内のユーザidの比較で編集・削除ボタンを非表示にする
                            $(`#message-${data.message.id}`).find('.crud-area').hide()
                        }else{
                            $('.input-message-body').val('');
                        }
                        break;
                    case "update":
                        $(`#message-${data.message.id}`).replaceWith(data.html);
                        if( $(`#message-${data.message.id}`).data("senderId") != currentUserId ){
                            // 送信部のidとルーム内のユーザidの比較で編集・削除ボタンを非表示にする
                            $(`#message-${data.message.id}`).find('.crud-area').hide()
                        }else{
                            $("#message-edit-modal").modal('hide');
                        }
                        break;
                    case "delete":
                        $(`#message-${data.message.id}`).remove();
                        break;
                }
            }
        })
    }
})