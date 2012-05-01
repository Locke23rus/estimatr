$(document).ready(function() {
  $('#reset-cards').on('click', function(e) {
    e.preventDefault();
    $.post('/rooms/' + room + '/reset');
  });

  $('#open-cards').on('click', function(e) {
    e.preventDefault();
    requestOpenCards();
  });


  $('.card').on('click', function(e) {
    e.preventDefault();

    if ($(this).hasClass('enabled')) return;

    resetCards();
    $(this).addClass('enabled');
    $.post('/rooms/' + room + '/vote', { card: $(this).data('card') });
  });
});

var resetCards = function() {
  $('.card.enabled').removeClass('enabled');
};

var resetMembers = function() {
  $('.member.voted').removeClass('voted');
};

var resetMembers = function() {
  $('.member.voted').removeClass('voted');
};

var resetResult = function() {
  $('#result').html('');
};

var resetAll = function() {
  resetCards();
  resetMembers();
  resetResult();
};

var updateMemberCount = function(count) {
  $('#member-count').text(count).data('count', count);
};

var addMember = function(id, info) {
  $('#members').append('<div id="' + id + '" class="member" data-login="' + info.login + '">' + info.login + '</div>');
  updateMemberCount($('.member').size());
};

var removeMember = function(id) {
  $('#' + id).fadeOut().remove();
  updateMemberCount($('.member').size());
};


var voteMember = function(id) {
  $('#' + id).addClass('voted');
};

var getVotes = function() {
  $.get('/rooms/' + room + '/votes', function(data) {
    $.each(data, function(i, login) {
      $(".member[data-login='" + login + "']").addClass('voted');
    });
  });
};

var requestOpenCards = function() {
  $.post('/rooms/' + room + '/open');
};

var openCards = function(votes) {
  resetResult();
  $('#result').append('<p>Results:</p>');
  $.each(votes, function(login, card) {
    $('#result').append('<div>' + card + ' - ' + login +'</div>');
  });
};

var checkVotes = function() {
  if (parseInt($('#member-count').data('count'), 10) == $('.member.voted').size()) {
    requestOpenCards();
  }
};
