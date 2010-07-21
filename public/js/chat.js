$(function()
{
  var chatbox = $('#chatbox'), lastId, untilId;
  function appendMsg(msg)
  {
    var wasAtBottom = (chatbox[0].scrollHeight - chatbox.scrollTop() <= chatbox.outerHeight()),
      msg = $('<p><b>'+msg.name+':</b> '+decodeURIComponent(msg.message)+'</p>');
    chatbox.append(msg);
    if(wasAtBottom)
       chatbox.scrollTop(chatbox[0].scrollHeight);
    return msg;
  }
  function parseResponse(response)
  {
    lastId = +response.last_id;
    for(var i = 0; i < response.messages.length; i += 1)
      appendMsg(response.messages[i]);
  }
  var gettingOlder = false;
  function getOlder(){
    if(gettingOlder || untilId <= 0 || chatbox.scrollTop() > 200)
      return;
    gettingOlder = true;
    var end = untilId - 1;
    untilId = (untilId <= 10 ? 0 : untilId - 10);
    $.getJSON('/chat/'+room_name+'/messages', { start: untilId, end: end }, function(response)
    {
      for(var i = response.messages.length - 1; i >= 0; i -= 1)
        chatbox.scrollTop(chatbox.scrollTop()+$('<p><b>'+response.messages[i].name+':</b> '+decodeURIComponent(response.messages[i].message)+'</p>').prependTo(chatbox).outerHeight(true));
     gettingOlder = false;
    });
  }
  //first request to get latest 20 messages
  $.getJSON('/chat/'+room_name+'/messages', { start: -20, end: -1 }, function(response)
  {
    if(!response || !response.status)
    {
      $('#loading').text('Oops, sorry, there was a problem loading messages.');
      return;
    }
    $('#loading').remove();
    parseResponse(response);
    untilId = lastId - 19;
    //now that the first request went through, all the initialization code
    chatbox.scroll(getOlder);
    var faye = new Faye.Client('/faye', {timeout: 120}), myOwnMsgs = [];
    faye.subscribe('/'+room_name, function(msg)
    {
      for(var i = 0, str = msg.name+':'+msg.message; i < myOwnMsgs.length; i += 1)
        if(myOwnMsgs[i] && myOwnMsgs[i].str === str)
        {
          if(!username)
            location += '?name=' + msg.name;
          myOwnMsgs[i].jQ.css('color','black');
          delete myOwnMsgs[i];
          while(myOwnMsgs.length && !myOwnMsgs[myOwnMsgs.length - 1])
            myOwnMsgs.length -= 1;
          return;
        }
      appendMsg(msg);
    });
    var preventDefault;
    $('.mathquill-textbox').keydown(function(e)
    {
      var jQ = $(this);
      if(e.which === 13 && !e.shiftKey && !(e.ctrlKey || e.metaKey) &&
          jQ.children(':not(.textarea,.cursor):first').length) //ensure nonempty
      {
        preventDefault = true;
        var msg = {};
        msg.name = username || prompt('What\'s your name?','Nameless Lady in the Hood');
        if(!msg.name)
          return false;
        msg.message = encodeURIComponent(jQ.blur().mathquill('html'));
        myOwnMsgs[myOwnMsgs.length] = {
          str: msg.name+':'+msg.message,
          jQ: appendMsg(msg).css('color','#445')
        };
        faye.publish('/'+room_name, msg);
        jQ.focus().trigger({ type: 'keydown', ctrlKey: true, which: 65 })
            .trigger({ type: 'keydown', which: 8 }); //ctrl-A, then backspace
        return false;
      }
    }).keypress(function()
    {
      if(preventDefault)
      {
        preventDefault = false;
        return false;
      }
    }).focus();
  });
});
