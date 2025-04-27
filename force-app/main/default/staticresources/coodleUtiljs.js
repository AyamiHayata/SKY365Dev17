function moveUpOnTime(obj1,idname) {
  // tr行を取得
  var line1 = obj1.parentNode.parentNode;
  // 一番上の行のときは終了する
  let regexp = /^header/;
  if(regexp.test(line1.previousElementSibling.id)) {
    alert("１番上の行です");
    return;
  }
  //　行のIDを取得し移動
  a = line1.id;
  $("#" + a).insertBefore(line1.previousElementSibling);
  // table要素を取得
  var tableElem = line1.parentNode;
  //hiddenで持っている行ナンバーを更新する
  renumberHiddenTableRow();

}

function moveDownOnTime(obj1,idname) {
  // tr行を取得
  var line1 = obj1.parentNode.parentNode;
  // 一番下の行のときは終了する
  if(line1.nextElementSibling === null) {
    alert("１番下の行です");
    return;
  }
  //　行のIDを取得し移動
  a = line1.id;
  $("#" + a).insertAfter(line1.nextElementSibling);

  // table要素を取得
  var tableElem = line1.parentNode;
  //hiddenで持っている行ナンバーを更新する
  renumberHiddenTableRow();

}

function renumberHiddenTableRow(){

  $('#on_display_order1').val($('#1').index());
  $('#on_display_order2').val($('#2').index());
  $('#on_display_order3').val($('#3').index());

  $('#off_display_order1').val($('#11').index());
  $('#off_display_order2').val($('#22').index());
  $('#off_display_order3').val($('#33').index());

}