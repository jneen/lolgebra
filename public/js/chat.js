$(function()
{
  var data = PAGE_DATA;
  if(!/^\?name=/.test(location.search))
    location += '?name=' + prompt('What\'s your name?', 'Nameless Lady in the Hood');
  var lastId, untilId;
  function appendMsg(msg)
  {
    var wasAtBottom = (chatbox[0].scrollHeight - chatbox.scrollTop() <= chatbox.outerHeight());
    chatbox.append('<p><b>'+msg.name+':</b> '+decodeURIComponent(msg.message)+'</p>')
    if(wasAtBottom)
       chatbox.scrollTop(chatbox[0].scrollHeight);
  }
  function parseResponse(response)
  {
    lastId = +response.last_id;
    for(var i = 0; i < response.messages.length; i += 1)
      appendMsg(response.messages[i]);
  }
  var gettingOlder = false, chatbox = $('#chatbox');
  function getOlder(){
    if(gettingOlder || untilId <= 0 || chatbox.scrollTop() > 200)
      return;
    gettingOlder = true;
    var end = untilId - 1;
    untilId = (untilId <= 10 ? 0 : untilId - 10);
    $.getJSON('/chat/'+data.room_name+'/messages', { start: untilId, end: end }, function(response)
    {
      for(var i = response.messages.length - 1; i >= 0; i -= 1)
        chatbox.scrollTop(chatbox.scrollTop()+$('<p><b>'+response.messages[i].name+':</b> '+decodeURIComponent(response.messages[i].message)+'</p>').prependTo(chatbox).outerHeight(true));
     gettingOlder = false;
    });
  }
  //first request to get latest 20 messages
  $.getJSON('/chat/'+data.room_name+'/messages', { start: -20, end: -1 }, function(response)
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
    faye.subscribe('/'+data.room_name, function(msg)
    {
      var i = $.inArray(msg.name+':'+msg.message, myOwnMsgs);
      if(i < 0)
        appendMsg(msg);
      else
        delete myOwnMsgs[i];
    });
    var preventDefault;
    $('.mathquill-textbox').keydown(function(e)
    {
      var jQ = $(this);
      if(e.which === 13 && !e.shiftKey && !(e.ctrlKey || e.metaKey) &&
          jQ.find(':first:not(.cursor)').length) //ensure nonempty
      {
        var msg = {
          name: data.username,
          message: encodeURIComponent(jQ.blur().html().replace(/<span class="cursor blink"><\/span>/i,''))
        };
        myOwnMsgs[myOwnMsgs.length] = msg.name+':'+msg.message;
        faye.publish('/'+data.room_name, msg);
        appendMsg(msg);
        jQ.focus().trigger({ type: 'keydown', ctrlKey: true, which: 65 })
            .trigger({ type: 'keydown', which: 8 }); //ctrl-A, then backspace
        preventDefault = true;
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
