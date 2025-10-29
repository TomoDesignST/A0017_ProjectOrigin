// let foo = false;
$.onStart(() => {
    let weaponBaseDamage = 1;
    $.setStateCompat("owner", "weaponBaseDamage", weaponBaseDamage);

    
});



$.onInteract((player) => {
 //playerに対してPlayerScriptをセットする
    $.setPlayerScript(player);

    // PlayerScriptを与えたプレイヤーの履歴をstateに記録する
    $.state.players = [];

    //まず、Player情報をPlayerScriptに送る
    if ($.state.players.find(p => p.id === player.id)) {
        // すでにPlayerScriptを与えたplayerにはメッセージを送る
        player.send("send", "")
    } else {
        // stateの履歴に存在しないplayerにはPlayerScriptを与えて履歴に記録する
        $.setPlayerScript(player);
        $.state.players = [...$.state.players, player]
    }

    // 存在しなくなったプレイヤーを履歴から取り除く
    $.state.players = $.state.players.filter(p => p.exists());

});

$.onReceive((messageType, arg, sender) => {
    if (messageType === "hello") {
        // "hello"メッセージを受け取ったらログに表示する
        $.log("hello " + arg);
        let weaponBaseDamage = arg;

        //weponBaseDamageのギミック側の上書き
        $.setStateCompat("owner", "weaponBaseDamage", weaponBaseDamage);
    }
});
//$.onInteract((playerHandle) => {
//    let foo = playerHandle.getAccessoryProductIds();
//    if (foo.includes("b096b7cf-24d9-46d2-ad3b-8e7c331c7e86")){
//        let weaponBaseDamage = 5;
//        $.setStateCompat("owner", "weaponBaseDamage", weaponBaseDamage);
//        }  
//});

//$.onUpdate(deltaTime => {
 //
 //  let foo = $.getStateCompat("owner", "AttackCalc", "boolean");
 //      if(foo){ 
// let weaponDamage = $.getStateCompat("owner", "weaponDamage", weaponDamage);
 //$.log(weaponDamage);
 //foo = False;}
//});

//$.onStart((playerHandle) => {
  // PlayerHandle に自身が持っている PlayerScript をセットする
//  $.setPlayerScript(playerHandle);
//});